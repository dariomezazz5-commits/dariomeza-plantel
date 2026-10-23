require "test_helper"

class SolicitudTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  setup do
    @s = solicitudes(:vacaciones_valentina)
    @jefe = users(:benjamin)
  end

  test "aprobar descuenta saldo, registra auditoría y avisa al colaborador" do
    assert_difference -> { RegistroAuditoria.count } do
      assert_enqueued_emails 1 do
        @s.aprobar!(por: @jefe)
      end
    end
    assert_equal "Aprobada", @s.reload.estado
    assert_equal @jefe, @s.resuelta_por
    assert_equal 12, @s.colaborador.reload.saldo_vacaciones
    assert_equal "solicitud.aprobada", RegistroAuditoria.last.accion
    assert_equal @jefe, RegistroAuditoria.last.user
  end

  test "deshacer devuelve el saldo" do
    @s.aprobar!(por: @jefe)
    @s.deshacer!(por: @jefe)
    assert @s.reload.pendiente?
    assert_equal 17, @s.colaborador.reload.saldo_vacaciones
  end

  test "rechazar no toca el saldo" do
    @s.rechazar!(por: @jefe)
    assert_equal "Rechazada", @s.reload.estado
    assert_equal 17, @s.colaborador.reload.saldo_vacaciones
  end

  test "no permite resolver dos veces" do
    @s.aprobar!(por: @jefe)
    assert_raises(ActiveRecord::RecordInvalid) { @s.rechazar!(por: @jefe) }
  end

  test "al crearla avisa a la jefatura directa" do
    assert_enqueued_email_with SolicitudesMailer, :nueva, args: ->(args) { args.first.is_a?(Solicitud) } do
      Solicitud.create!(colaborador: colaboradores(:valentina), tipo: "Vacaciones", desde: Date.new(2026, 12, 1), hasta: Date.new(2026, 12, 2))
    end
    assert_equal [ "benjamin@industriasandes.cl" ], SolicitudesMailer.nueva(Solicitud.last).to
  end

  test "sin jefatura con acceso, avisa a RR.HH." do
    s = solicitudes(:permiso_matias) # su jefa es Camila (admin)
    assert_equal [ "camila@industriasandes.cl" ], SolicitudesMailer.nueva(s).to
  end

  test "hasta debe ser posterior a desde" do
    s = Solicitud.new(colaborador: colaboradores(:camila), tipo: "Vacaciones", desde: Date.new(2026, 11, 10), hasta: Date.new(2026, 11, 9))
    assert_not s.valid?
    assert s.errors.key?(:hasta)
  end
end

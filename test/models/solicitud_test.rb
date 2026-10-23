require "test_helper"

class SolicitudTest < ActiveSupport::TestCase
  setup { @s = solicitudes(:vacaciones_valentina) }

  test "aprobar descuenta saldo de vacaciones y deshacer lo devuelve" do
    @s.aprobar!
    assert_equal "Aprobada", @s.reload.estado
    assert_equal 12, @s.colaborador.reload.saldo_vacaciones

    @s.deshacer!
    assert @s.reload.pendiente?
    assert_equal 17, @s.colaborador.reload.saldo_vacaciones
  end

  test "rechazar no toca el saldo" do
    @s.rechazar!
    assert_equal "Rechazada", @s.reload.estado
    assert_equal 17, @s.colaborador.reload.saldo_vacaciones
  end

  test "no permite resolver dos veces" do
    @s.aprobar!
    assert_raises(ActiveRecord::RecordInvalid) { @s.rechazar! }
  end

  test "hasta debe ser posterior a desde" do
    s = Solicitud.new(colaborador: colaboradores(:camila), tipo: "Vacaciones", desde: Date.new(2026, 11, 10), hasta: Date.new(2026, 11, 9))
    assert_not s.valid?
    assert s.errors.key?(:hasta)
  end
end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin ve y aprueba a toda la empresa, salvo lo propio" do
    u = users(:camila)
    assert_equal 4, u.colaboradores_visibles.count
    assert u.puede_aprobar?(solicitudes(:vacaciones_valentina))
    assert u.puede_aprobar?(solicitudes(:permiso_matias))
  end

  test "jefatura ve y aprueba solo a su equipo directo" do
    u = users(:benjamin)
    assert_equal [ colaboradores(:benjamin), colaboradores(:valentina) ].sort, u.colaboradores_visibles.to_a.sort
    assert u.puede_aprobar?(solicitudes(:vacaciones_valentina))
    assert_not u.puede_aprobar?(solicitudes(:permiso_matias))
  end

  test "colaborador solo se ve a sí mismo y no aprueba" do
    u = users(:valentina)
    assert_equal [ colaboradores(:valentina) ], u.colaboradores_visibles.to_a
    assert_not u.puede_aprobar?(solicitudes(:vacaciones_valentina))
    assert_not u.puede_solicitar_para?(colaboradores(:matias))
  end

  test "contraseña de al menos 10 caracteres" do
    u = users(:valentina)
    u.password = "corta"
    assert_not u.valid?
  end

  test "verificación en dos pasos no acepta el mismo código dos veces" do
    u = users(:valentina)
    secret = ROTP::Base32.random
    codigo = ROTP::TOTP.new(secret).now
    assert u.otp_valido?(codigo, secret:)
    u.activar_dos_pasos!(secret)
    assert_not u.otp_valido?(codigo)
  end
end

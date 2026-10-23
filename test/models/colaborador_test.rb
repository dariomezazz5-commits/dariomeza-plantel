require "test_helper"

class ColaboradorTest < ActiveSupport::TestCase
  test "iniciales, nombre corto y jefatura" do
    c = colaboradores(:valentina)
    assert_equal "VM", c.iniciales
    assert_equal "Valentina Muñoz", c.nombre_corto
    assert_equal "Benjamín Contreras", c.jefatura
    assert_equal "Gerencia General", colaboradores(:camila).jefatura
  end

  test "antigüedad en meses o años" do
    c = colaboradores(:camila)
    assert_equal "7 años", c.antiguedad(Date.new(2026, 10, 23))
    c.ingreso = Date.new(2026, 9, 1)
    assert_equal "1 mes", c.antiguedad(Date.new(2026, 10, 23))
  end

  test "valida RUT y que no se repita en la empresa" do
    c = colaboradores(:camila).dup
    assert_not c.valid?
    assert c.errors.key?(:rut)
    c.rut = "12.345.678-9"
    assert_not c.valid?
    assert_match "dígito verificador", c.errors[:rut].join
  end

  test "solo ve colaboradores de la empresa actual" do
    assert_not_includes Colaborador.all, colaboradores(:rosa)
    ActsAsTenant.with_tenant(empresas(:austral)) { assert_equal [ colaboradores(:rosa) ], Colaborador.all.to_a }
  end
end

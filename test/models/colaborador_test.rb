require "test_helper"

class ColaboradorTest < ActiveSupport::TestCase
  test "iniciales y nombre corto" do
    c = colaboradores(:valentina)
    assert_equal "VM", c.iniciales
    assert_equal "Valentina Muñoz", c.nombre_corto
  end

  test "antigüedad en meses o años" do
    c = colaboradores(:camila)
    assert_equal "7 años", c.antiguedad(Date.new(2026, 10, 23))
    c.ingreso = Date.new(2025, 10, 20)
    assert_equal "1 año", c.antiguedad(Date.new(2026, 10, 23))
    c.ingreso = Date.new(2026, 9, 1)
    assert_equal "1 mes", c.antiguedad(Date.new(2026, 10, 23))
  end

  test "búsqueda por nombre, cargo o RUT" do
    assert_equal [ colaboradores(:valentina) ], Colaborador.buscar("ingeniera").to_a
    assert_equal [ colaboradores(:camila) ], Colaborador.buscar("14.238").to_a
  end
end

require "test_helper"

class DiasHabilesTest < ActiveSupport::TestCase
  test "cuenta lunes a viernes" do
    assert_equal 5, DiasHabiles.contar(Date.new(2026, 11, 9), Date.new(2026, 11, 13))
    assert_equal 10, DiasHabiles.contar(Date.new(2026, 11, 16), Date.new(2026, 11, 27))
    assert_equal 6, DiasHabiles.contar(Date.new(2026, 11, 23), Date.new(2026, 11, 30))
  end

  test "descuenta feriados" do
    # 8 dic 2026 (martes) es feriado
    assert_equal 4, DiasHabiles.contar(Date.new(2026, 12, 7), Date.new(2026, 12, 11))
  end

  test "rango invertido es cero" do
    assert_equal 0, DiasHabiles.contar(Date.new(2026, 11, 13), Date.new(2026, 11, 9))
  end
end

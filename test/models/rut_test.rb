require "test_helper"

class RutTest < ActiveSupport::TestCase
  test "valida el dígito verificador" do
    assert Rut.valido?("12.345.678-5")
    assert Rut.valido?("123456785")
    assert Rut.valido?("8.765.432-k")
    assert_not Rut.valido?("12.345.678-9")
    assert_not Rut.valido?("abc")
  end

  test "formatea con puntos y guion" do
    assert_equal "12.345.678-5", Rut.formatear("123456785")
    assert_equal "8.765.432-K", Rut.formatear("8765432k")
  end
end

# RUT chileno: normalización a "12.345.678-9" y validación del dígito verificador (módulo 11).
module Rut
  def self.limpiar(valor)
    valor.to_s.upcase.gsub(/[^0-9K]/, "")
  end

  def self.dv(cuerpo)
    suma = cuerpo.to_s.reverse.chars.each_with_index.sum { |d, i| d.to_i * [ 2, 3, 4, 5, 6, 7 ][i % 6] }
    resto = 11 - (suma % 11)
    { 11 => "0", 10 => "K" }.fetch(resto, resto.to_s)
  end

  def self.valido?(valor)
    limpio = limpiar(valor)
    return false if limpio.length < 2
    cuerpo, digito = limpio[0..-2], limpio[-1]
    cuerpo.match?(/\A\d+\z/) && dv(cuerpo) == digito
  end

  def self.formatear(valor)
    limpio = limpiar(valor)
    return valor.to_s.strip if limpio.length < 2
    cuerpo, digito = limpio[0..-2], limpio[-1]
    "#{cuerpo.reverse.scan(/\d{1,3}/).join('.').reverse}-#{digito}"
  end
end

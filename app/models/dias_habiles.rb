# Días hábiles = lunes a viernes, descontando feriados de config/feriados.yml.
module DiasHabiles
  def self.feriados
    @feriados ||= YAML.load_file(Rails.root.join("config/feriados.yml"), permitted_classes: [ Date ]).map(&:to_date).to_set
  end

  def self.habil?(fecha)
    !fecha.saturday? && !fecha.sunday? && !feriados.include?(fecha)
  end

  def self.contar(desde, hasta)
    return 0 if desde.blank? || hasta.blank? || hasta < desde
    (desde..hasta).count { |d| habil?(d) }
  end

  def self.etiqueta(n)
    "#{n} #{n == 1 ? 'día hábil' : 'días hábiles'}"
  end
end

class Colaborador < ApplicationRecord
  AREAS = %w[Operaciones Comercial Tecnología Finanzas Personas].freeze

  has_many :solicitudes, -> { order(:id) }, dependent: :destroy

  validates :nombre, :cargo, :area, :sede, :ingreso, :contrato, :rut, :email, presence: true
  validates :area, inclusion: { in: AREAS }

  scope :ausentes, -> { where.not(estado: "Activo") }

  def self.buscar(q)
    q = q.to_s.strip
    return all if q.blank?
    patron = "%#{sanitize_sql_like(q)}%"
    t = arel_table
    where(t[:nombre].matches(patron).or(t[:cargo].matches(patron)).or(t[:rut].matches(patron)))
  end

  def self.del_area(area)
    AREAS.include?(area) ? where(area: area) : all
  end

  # "Camila Rojas Fuentes" -> "Camila Rojas"
  def nombre_corto = nombre.split.first(2).join(" ")
  def nombre_pila = nombre.split.first
  def iniciales = nombre.split.first(2).map { |p| p[0] }.join
  def activo? = estado == "Activo"

  def antiguedad(hoy = Date.current)
    meses = (hoy.year - ingreso.year) * 12 + (hoy.month - ingreso.month)
    if meses < 12
      "#{meses} #{meses == 1 ? 'mes' : 'meses'}"
    else
      anios = meses / 12
      "#{anios} #{anios == 1 ? 'año' : 'años'}"
    end
  end
end

class Colaborador < ApplicationRecord
  CONTRATOS = [ "Indefinido", "Plazo fijo", "Por obra o faena" ].freeze
  ESTADOS = [ "Activo", "Vacaciones", "Licencia médica" ].freeze

  acts_as_tenant :empresa

  belongs_to :jefe, class_name: "Colaborador", optional: true
  has_many :equipo, class_name: "Colaborador", foreign_key: :jefe_id, dependent: :nullify, inverse_of: :jefe
  has_many :solicitudes, -> { order(:id) }, dependent: :destroy
  has_one :user, dependent: :nullify

  normalizes :rut, with: ->(r) { Rut.formatear(r) }
  normalizes :email, with: ->(e) { e.strip.downcase }
  normalizes :nombre, :cargo, :area, :sede, with: ->(v) { v.squish }

  validates :nombre, :cargo, :area, :sede, :ingreso, :rut, :email, presence: true
  validates :contrato, inclusion: { in: CONTRATOS }
  validates :estado, inclusion: { in: ESTADOS }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :saldo_vacaciones, numericality: { only_integer: true }
  validates_uniqueness_to_tenant :rut
  validate :rut_valido
  validate :jefe_valido

  scope :ausentes, -> { where.not(estado: "Activo") }

  def self.buscar(q)
    q = q.to_s.strip
    return all if q.blank?
    patron = "%#{sanitize_sql_like(q)}%"
    t = arel_table
    where(t[:nombre].matches(patron).or(t[:cargo].matches(patron)).or(t[:rut].matches(patron)))
  end

  def self.del_area(area)
    area.present? && area != "Todas" ? where(area: area) : all
  end

  # "Camila Rojas Fuentes" -> "Camila Rojas"
  def nombre_corto = nombre.split.first(2).join(" ")
  def nombre_pila = nombre.split.first
  def iniciales = nombre.split.first(2).map { |p| p[0] }.join.upcase
  def activo? = estado == "Activo"
  def jefatura = jefe&.nombre_corto || "Gerencia General"

  def antiguedad(hoy = Date.current)
    meses = (hoy.year - ingreso.year) * 12 + (hoy.month - ingreso.month)
    if meses < 12
      "#{meses} #{meses == 1 ? 'mes' : 'meses'}"
    else
      anios = meses / 12
      "#{anios} #{anios == 1 ? 'año' : 'años'}"
    end
  end

  private
    def rut_valido
      errors.add(:rut, "no es válido (revisa el dígito verificador)") if rut.present? && !Rut.valido?(rut)
    end

    def jefe_valido
      return unless jefe
      errors.add(:jefe, "no puede ser la misma persona") if jefe_id == id && persisted?
      errors.add(:jefe, "debe ser de la misma empresa") if jefe.empresa_id != empresa_id
    end
end

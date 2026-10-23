class Empresa < ApplicationRecord
  has_many :colaboradores, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :solicitudes, dependent: :destroy
  has_many :proximos_ingresos, dependent: :destroy
  has_many :registros_auditoria, dependent: :delete_all

  normalizes :rut, with: ->(r) { Rut.formatear(r) }
  validates :nombre, presence: true
  validates :rut, presence: true, uniqueness: true

  def areas
    colaboradores.distinct.order(:area).pluck(:area)
  end
end

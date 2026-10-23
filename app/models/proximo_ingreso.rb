class ProximoIngreso < ApplicationRecord
  acts_as_tenant :empresa
  scope :vigentes, -> { where(fecha: Date.current..).order(:fecha) }
end

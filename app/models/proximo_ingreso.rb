class ProximoIngreso < ApplicationRecord
  scope :vigentes, -> { where(fecha: Date.current..).order(:fecha) }
end

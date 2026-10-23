# Bitácora inmutable de acciones relevantes: quién hizo qué, sobre qué registro y cuándo.
class RegistroAuditoria < ApplicationRecord
  acts_as_tenant :empresa

  belongs_to :user, optional: true
  belongs_to :recurso, polymorphic: true, optional: true

  validates :accion, :descripcion, presence: true

  ACCIONES = {
    "sesion.iniciada" => "Inicio de sesión",
    "sesion.dos_pasos_activada" => "Verificación en dos pasos activada",
    "sesion.dos_pasos_desactivada" => "Verificación en dos pasos desactivada",
    "colaborador.creado" => "Colaborador creado",
    "colaborador.actualizado" => "Colaborador actualizado",
    "colaborador.importacion" => "Importación de colaboradores",
    "acceso.creado" => "Acceso creado",
    "acceso.actualizado" => "Acceso actualizado",
    "solicitud.creada" => "Solicitud creada",
    "solicitud.aprobada" => "Solicitud aprobada",
    "solicitud.rechazada" => "Solicitud rechazada",
    "solicitud.deshecha" => "Resolución deshecha"
  }.freeze

  def self.registrar!(accion, descripcion, recurso: nil, cambios: {}, user: Current.user, empresa: nil)
    empresa ||= ActsAsTenant.current_tenant || user&.empresa
    ActsAsTenant.with_tenant(empresa) do
      create!(accion:, descripcion:, recurso:, cambios:, user:, ip_address: Current.ip_address, empresa:)
    end
  end

  def readonly? = persisted?
  def accion_legible = ACCIONES.fetch(accion, accion)
end

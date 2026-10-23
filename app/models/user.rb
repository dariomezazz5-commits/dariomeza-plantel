class User < ApplicationRecord
  ROLES = {
    "admin" => "Administrador de RR.HH.",
    "jefatura" => "Jefatura",
    "colaborador" => "Colaborador"
  }.freeze

  has_secure_password reset_token: { expires_in: 24.hours }
  has_many :sessions, dependent: :destroy
  belongs_to :empresa
  belongs_to :colaborador, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :rol, inclusion: { in: ROLES.keys }
  validates :password, length: { minimum: 10, message: "debe tener al menos 10 caracteres" }, allow_nil: true
  validates :colaborador, presence: { message: "es obligatorio para este rol" }, unless: :admin?
  validates :colaborador_id, uniqueness: true, allow_nil: true
  validate :colaborador_de_la_misma_empresa

  ROLES.each_key { |r| define_method(:"#{r}?") { rol == r } }

  def rol_legible = ROLES.fetch(rol)
  def nombre = colaborador&.nombre_corto || email_address
  def nombre_pila = colaborador&.nombre_pila || email_address.split("@").first
  def iniciales = colaborador&.iniciales || email_address[0, 2].upcase
  def cargo = colaborador&.cargo || rol_legible

  # --- Permisos ---------------------------------------------------------
  # admin: toda la empresa · jefatura: su ficha y su equipo directo · colaborador: solo su ficha.
  def colaboradores_visibles
    return Colaborador.all if admin?
    return Colaborador.none unless colaborador
    ids = [ colaborador_id ]
    ids += colaborador.equipo.ids if jefatura?
    Colaborador.where(id: ids)
  end

  def solicitudes_visibles
    admin? ? Solicitud.all : Solicitud.where(colaborador_id: colaboradores_visibles.select(:id))
  end

  # Solicitudes que esta persona puede aprobar (nadie aprueba las propias).
  def solicitudes_aprobables
    base = if admin?
      Solicitud.all
    elsif jefatura?
      Solicitud.where(colaborador_id: colaborador.equipo.select(:id))
    else
      Solicitud.none
    end
    colaborador_id ? base.where.not(colaborador_id: colaborador_id) : base
  end

  def puede_aprobar?(solicitud) = solicitudes_aprobables.exists?(solicitud.id)
  def puede_ver?(colaborador) = colaboradores_visibles.exists?(colaborador.id)
  def puede_solicitar_para?(colaborador) = colaborador.present? && puede_ver?(colaborador)
  def puede_administrar? = admin?

  # --- Verificación en dos pasos (TOTP) ---------------------------------
  def dos_pasos_activo? = otp_activado_en.present?


  def otp_valido?(codigo, secret: otp_secret)
    return false if secret.blank?
    momento = ROTP::TOTP.new(secret, issuer: "Plantel")
      .verify(codigo.to_s.gsub(/\D/, ""), drift_behind: 30, drift_ahead: 15, after: otp_ultimo_uso_en)
    return false unless momento
    update_column(:otp_ultimo_uso_en, Time.zone.at(momento)) # evita reutilizar el mismo código
    true
  end

  def activar_dos_pasos!(secret)
    update!(otp_secret: secret, otp_activado_en: Time.current)
  end

  def desactivar_dos_pasos!
    update!(otp_secret: nil, otp_activado_en: nil, otp_ultimo_uso_en: nil)
  end

  private
    def colaborador_de_la_misma_empresa
      errors.add(:colaborador, "debe ser de la misma empresa") if colaborador && colaborador.empresa_id != empresa_id
    end
end

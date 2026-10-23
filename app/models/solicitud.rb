class Solicitud < ApplicationRecord
  TIPOS = [ "Vacaciones", "Permiso administrativo", "Licencia médica" ].freeze
  ESTADOS = %w[Pendiente Aprobada Rechazada].freeze

  acts_as_tenant :empresa

  belongs_to :colaborador
  belongs_to :creada_por, class_name: "User", optional: true
  belongs_to :resuelta_por, class_name: "User", optional: true

  validates :tipo, inclusion: { in: TIPOS }
  validates :estado, inclusion: { in: ESTADOS }
  validates :desde, :hasta, presence: true
  validate :rango_valido

  scope :pendientes, -> { where(estado: "Pendiente") }
  scope :resueltas, -> { where.not(estado: "Pendiente") }

  after_create_commit :notificar_creacion

  def self.nueva_con_defaults(colaborador: nil)
    # Por defecto: primera semana hábil del mes siguiente (lunes a viernes).
    lunes = Date.current.next_month.beginning_of_month
    lunes += 1 until lunes.monday?
    new(tipo: "Vacaciones", desde: lunes, hasta: lunes + 4, colaborador:)
  end

  def pendiente? = estado == "Pendiente"
  def vacaciones? = tipo == "Vacaciones"
  def dias_habiles = DiasHabiles.contar(desde, hasta)
  def resumen = "#{tipo} de #{colaborador.nombre_corto} (#{desde.strftime('%d-%m-%Y')} al #{hasta.strftime('%d-%m-%Y')})"

  def aprobar!(por:)
    resolver!("Aprobada", por:) { colaborador.decrement!(:saldo_vacaciones, dias_habiles) if vacaciones? }
  end

  def rechazar!(por:)
    resolver!("Rechazada", por:)
  end

  def deshacer!(por:)
    return if pendiente?
    transaction do
      anterior = estado
      colaborador.increment!(:saldo_vacaciones, dias_habiles) if anterior == "Aprobada" && vacaciones?
      update!(estado: "Pendiente", resuelta_en: nil, resuelta_por: nil)
      RegistroAuditoria.registrar!("solicitud.deshecha", "Volvió a Pendiente: #{resumen}", recurso: self, user: por,
                                   cambios: { estado: [ anterior, "Pendiente" ] })
    end
  end

  private
    def resolver!(nuevo_estado, por:)
      raise ActiveRecord::RecordInvalid, self unless pendiente?
      transaction do
        yield if block_given?
        update!(estado: nuevo_estado, resuelta_en: Time.current, resuelta_por: por)
        accion = nuevo_estado == "Aprobada" ? "solicitud.aprobada" : "solicitud.rechazada"
        RegistroAuditoria.registrar!(accion, "#{nuevo_estado}: #{resumen}", recurso: self, user: por,
                                     cambios: { estado: [ "Pendiente", nuevo_estado ] })
      end
      SolicitudesMailer.resuelta(self).deliver_later
    end

    def notificar_creacion
      RegistroAuditoria.registrar!("solicitud.creada", "Creada: #{resumen}", recurso: self, user: creada_por, empresa: empresa)
      SolicitudesMailer.nueva(self).deliver_later
    end

    def rango_valido
      errors.add(:hasta, "debe ser igual o posterior a Desde") if desde && hasta && hasta < desde
    end
end

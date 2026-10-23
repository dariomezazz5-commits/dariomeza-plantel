class Solicitud < ApplicationRecord
  TIPOS = [ "Vacaciones", "Permiso administrativo", "Licencia médica" ].freeze
  ESTADOS = %w[Pendiente Aprobada Rechazada].freeze

  belongs_to :colaborador

  validates :tipo, inclusion: { in: TIPOS }
  validates :estado, inclusion: { in: ESTADOS }
  validates :desde, :hasta, presence: true
  validate :rango_valido

  scope :pendientes, -> { where(estado: "Pendiente") }
  scope :resueltas, -> { where.not(estado: "Pendiente") }

  def self.nueva_con_defaults
    # Por defecto: primera semana hábil del mes siguiente (lunes a viernes).
    lunes = Date.current.next_month.beginning_of_month
    lunes += 1 until lunes.monday?
    new(tipo: "Vacaciones", desde: lunes, hasta: lunes + 4)
  end

  def pendiente? = estado == "Pendiente"
  def vacaciones? = tipo == "Vacaciones"
  def dias_habiles = DiasHabiles.contar(desde, hasta)

  def aprobar!
    resolver!("Aprobada") { colaborador.decrement!(:saldo_vacaciones, dias_habiles) if vacaciones? }
  end

  def rechazar!
    resolver!("Rechazada")
  end

  def deshacer!
    return if pendiente?
    transaction do
      colaborador.increment!(:saldo_vacaciones, dias_habiles) if estado == "Aprobada" && vacaciones?
      update!(estado: "Pendiente", resuelta_en: nil)
    end
  end

  private
    def resolver!(nuevo_estado)
      raise ActiveRecord::RecordInvalid, self unless pendiente?
      transaction do
        yield if block_given?
        update!(estado: nuevo_estado, resuelta_en: Time.current)
      end
    end

    def rango_valido
      errors.add(:hasta, "debe ser igual o posterior a Desde") if desde && hasta && hasta < desde
    end
end

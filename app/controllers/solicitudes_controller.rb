class SolicitudesController < ApplicationController
  TABS = %w[pend done all].freeze

  before_action :set_solicitud, only: %i[aprobar rechazar deshacer]

  def index
    @tab = TABS.include?(params[:tab]) ? params[:tab] : "pend"
    @nueva_solicitud = Solicitud.nueva_con_defaults if params[:nueva]
    cargar_lista
  end

  # Se muestra como diálogo dentro del turbo-frame "modal" de la página de Ausencias.
  def new
    return redirect_to(ausencias_path(nueva: 1)) unless turbo_frame_request?
    @nueva_solicitud = Solicitud.nueva_con_defaults
  end

  def create
    @nueva_solicitud = Solicitud.new(solicitud_params.merge(estado: "Pendiente"))
    if @nueva_solicitud.save
      redirect_to ausencias_path(tab: "pend"), status: :see_other
    else
      @tab = "pend"
      cargar_lista
      render :index, status: :unprocessable_entity
    end
  end

  def aprobar
    @solicitud.aprobar!
    recordar_resuelta
    volver
  end

  def rechazar
    @solicitud.rechazar!
    recordar_resuelta
    volver
  end

  def deshacer
    @solicitud.deshacer!
    resueltas_en_sesion.delete(@solicitud.id)
    volver
  end

  private
    def set_solicitud
      @solicitud = Solicitud.find(params[:id])
    end

    def solicitud_params
      params.expect(solicitud: %i[colaborador_id tipo desde hasta])
    end

    def cargar_lista
      base = Solicitud.includes(:colaborador).order(:id)
      @solicitudes = case @tab
      when "pend" then base.pendientes
      when "done" then base.resueltas
      else base
      end
      @resueltas_en_sesion = resueltas_en_sesion
    end

    # "Deshacer" solo se ofrece para solicitudes resueltas en esta sesión (como en el prototipo).
    def resueltas_en_sesion
      session[:resueltas] ||= []
    end

    def recordar_resuelta
      resueltas_en_sesion << @solicitud.id unless resueltas_en_sesion.include?(@solicitud.id)
    end

    def volver
      redirect_back_or_to ausencias_path, status: :see_other
    end
end

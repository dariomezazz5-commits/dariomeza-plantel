class SolicitudesController < ApplicationController
  TABS = %w[pend done all].freeze

  before_action :set_solicitud, only: %i[aprobar rechazar deshacer]

  def index
    @tab = TABS.include?(params[:tab]) ? params[:tab] : default_tab
    @nueva_solicitud = nueva_solicitud if params[:nueva]
    cargar_lista
  end

  # Se muestra como diálogo dentro del turbo-frame "modal" de la página de Ausencias.
  def new
    return redirect_to(ausencias_path(nueva: 1)) unless turbo_frame_request?
    @nueva_solicitud = nueva_solicitud
  end

  def create
    @nueva_solicitud = Solicitud.new(solicitud_params.merge(estado: "Pendiente", creada_por: usuario_actual))
    @nueva_solicitud.colaborador = nil unless usuario_actual.puede_solicitar_para?(@nueva_solicitud.colaborador)
    if @nueva_solicitud.save
      redirect_to ausencias_path(tab: "pend"), status: :see_other, notice: "Solicitud creada. Avisamos por correo a quien debe aprobarla."
    else
      @tab = "pend"
      cargar_lista
      render :index, status: :unprocessable_entity
    end
  end

  def aprobar
    autorizar!(usuario_actual.puede_aprobar?(@solicitud))
    @solicitud.aprobar!(por: usuario_actual)
    recordar_resuelta
    volver
  end

  def rechazar
    autorizar!(usuario_actual.puede_aprobar?(@solicitud))
    @solicitud.rechazar!(por: usuario_actual)
    recordar_resuelta
    volver
  end

  def deshacer
    autorizar!(usuario_actual.puede_aprobar?(@solicitud) && resueltas_en_sesion.include?(@solicitud.id))
    @solicitud.deshacer!(por: usuario_actual)
    resueltas_en_sesion.delete(@solicitud.id)
    volver
  end

  private
    def set_solicitud
      @solicitud = usuario_actual.solicitudes_visibles.find(params[:id])
    end

    def solicitud_params
      params.expect(solicitud: %i[colaborador_id tipo desde hasta])
    end

    def default_tab = usuario_actual.colaborador? ? "all" : "pend"

    def nueva_solicitud
      propio = usuario_actual.colaborador if usuario_actual.colaborador?
      Solicitud.nueva_con_defaults(colaborador: propio)
    end

    def cargar_lista
      base = usuario_actual.solicitudes_visibles.includes(:colaborador, :resuelta_por).order(:desde, :id)
      @solicitudes = case @tab
      when "pend" then base.pendientes
      when "done" then base.resueltas
      else base
      end
      @aprobables = usuario_actual.solicitudes_aprobables.pluck(:id).to_set
      @resueltas_en_sesion = resueltas_en_sesion
      @colaboradores_para_solicitud = usuario_actual.colaboradores_visibles.order(:nombre)
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

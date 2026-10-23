class ColaboradoresController < ApplicationController
  def index
    @q = params[:q].to_s
    @area = Colaborador::AREAS.include?(params[:area]) ? params[:area] : "Todas"
    @total = Colaborador.count
    @colaboradores = Colaborador.buscar(@q).del_area(@area).order(:id)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # Se muestra como ficha lateral dentro del turbo-frame "drawer" del layout.
  def show
    @colaborador = Colaborador.includes(:solicitudes).find(params[:id])
    redirect_to colaboradores_path(ficha: @colaborador.id) unless turbo_frame_request?
  end
end

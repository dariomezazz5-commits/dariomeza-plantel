class InicioController < ApplicationController
  def show
    @colaboradores = Colaborador.all.to_a
    @pendientes = Solicitud.pendientes.includes(:colaborador).order(:id)
    @ingresos = ProximoIngreso.vigentes
    @dotacion = Colaborador.group(:area).count
  end
end

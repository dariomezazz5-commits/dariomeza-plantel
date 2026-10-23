class InicioController < ApplicationController
  def show
    return redirect_to(ausencias_path) if usuario_actual.colaborador?

    visibles = usuario_actual.colaboradores_visibles
    @colaboradores = visibles.to_a
    @pendientes = usuario_actual.solicitudes_aprobables.pendientes.includes(:colaborador).order(:id)
    @ingresos = usuario_actual.admin? ? ProximoIngreso.vigentes : ProximoIngreso.none
    @dotacion = visibles.group(:area).count.sort_by { |area, n| [ -n, area ] }
  end
end

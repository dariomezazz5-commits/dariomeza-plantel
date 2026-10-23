class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :usuario_actual, :pendientes_count

  private
    # TODO: reemplazar por autenticación real (y permisos de quién puede aprobar).
    def usuario_actual
      @usuario_actual ||= Colaborador.order(:id).first
    end

    def pendientes_count
      @pendientes_count ||= Solicitud.pendientes.count
    end
end

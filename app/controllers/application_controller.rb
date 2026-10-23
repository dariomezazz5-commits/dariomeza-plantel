class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern
  stale_when_importmap_changes

  set_current_tenant_through_filter
  before_action :registrar_ip
  before_action :asignar_empresa
  before_action :cargar_ficha

  helper_method :usuario_actual, :pendientes_count

  class NoAutorizado < StandardError; end
  rescue_from NoAutorizado, with: :sin_permiso
  rescue_from ActiveRecord::RecordNotFound, with: :sin_permiso

  private
    def usuario_actual = Current.user

    def registrar_ip
      Current.ip_address = request.remote_ip
    end

    def asignar_empresa
      set_current_tenant(Current.user.empresa) if authenticated?
    end

    # Enlace directo a una ficha: /cualquier-pagina?ficha=ID abre la ficha lateral.
    def cargar_ficha
      return unless params[:ficha].present? && usuario_actual
      @ficha = usuario_actual.colaboradores_visibles.includes(:solicitudes, :jefe, :user).find_by(id: params[:ficha])
    end

    # Solicitudes que el usuario conectado puede aprobar (badge del menú).
    def pendientes_count
      @pendientes_count ||= usuario_actual ? usuario_actual.solicitudes_aprobables.pendientes.count : 0
    end

    def autorizar!(permitido)
      raise NoAutorizado unless permitido
    end

    def solo_admin!
      autorizar!(usuario_actual.admin?)
    end

    def sin_permiso
      respond_to do |format|
        format.html { redirect_to root_path, alert: "No tienes permiso para ver eso o no existe." }
        format.any { head :not_found }
      end
    end
end

class ColaboradoresController < ApplicationController
  before_action :solo_admin!, except: %i[index show]
  before_action :set_colaborador, only: %i[show edit update]

  def index
    autorizar!(!usuario_actual.colaborador?)
    @q = params[:q].to_s
    @areas = usuario_actual.colaboradores_visibles.distinct.order(:area).pluck(:area)
    @area = @areas.include?(params[:area]) ? params[:area] : "Todas"
    @total = usuario_actual.colaboradores_visibles.count
    @colaboradores = usuario_actual.colaboradores_visibles.buscar(@q).del_area(@area).order(:nombre)

    # El buscador pide turbo_stream; cualquier otra visita (p. ej. tras guardar un formulario) recibe la página completa.
    if params.key?(:q)
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    else
      render :index, formats: :html
    end
  end

  # Se muestra como ficha lateral dentro del turbo-frame "drawer" del layout.
  def show
    redirect_to colaboradores_path(ficha: @colaborador.id) unless turbo_frame_request?
  end

  def new
    @colaborador = Colaborador.new(estado: "Activo", contrato: "Indefinido", ingreso: Date.current, saldo_vacaciones: 0)
  end

  def create
    @colaborador = Colaborador.new(colaborador_params)
    if guardar_con_acceso
      RegistroAuditoria.registrar!("colaborador.creado", "Creó la ficha de #{@colaborador.nombre}", recurso: @colaborador)
      redirect_to colaboradores_path(ficha: @colaborador.id), notice: "#{@colaborador.nombre_corto} fue agregado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @colaborador.assign_attributes(colaborador_params)
    cambios = @colaborador.changes.except("updated_at")
    if guardar_con_acceso
      if cambios.any?
        RegistroAuditoria.registrar!("colaborador.actualizado", "Actualizó la ficha de #{@colaborador.nombre}",
                                     recurso: @colaborador, cambios: cambios)
      end
      redirect_to colaboradores_path(ficha: @colaborador.id), notice: "Cambios guardados."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_colaborador
      @colaborador = usuario_actual.colaboradores_visibles.includes(:solicitudes, :jefe, :user).find(params[:id])
    end

    def colaborador_params
      params.expect(colaborador: %i[nombre rut email cargo area sede ingreso contrato estado saldo_vacaciones jefe_id])
    end

    def acceso_params
      params.fetch(:acceso, {}).permit(:habilitar, :rol)
    end

    # Guarda la ficha y, si se pidió, crea o actualiza su acceso a Plantel (enviando invitación al crearlo).
    def guardar_con_acceso
      habilitar = acceso_params[:habilitar] == "1"
      user = @colaborador.user
      invitar = false

      Colaborador.transaction do
        @colaborador.save!
        if habilitar
          rol = User::ROLES.key?(acceso_params[:rol]) ? acceso_params[:rol] : "colaborador"
          if user
            user.update!(rol:, email_address: @colaborador.email)
            RegistroAuditoria.registrar!("acceso.actualizado", "Rol de #{@colaborador.nombre_corto}: #{user.rol_legible}", recurso: user, cambios: user.saved_changes.slice("rol", "email_address")) if user.saved_changes.slice("rol", "email_address").any?
          else
            user = User.create!(empresa: Current.user.empresa, colaborador: @colaborador, email_address: @colaborador.email,
                                rol:, password: SecureRandom.base58(24))
            RegistroAuditoria.registrar!("acceso.creado", "Dio acceso a #{@colaborador.nombre_corto} como #{user.rol_legible}", recurso: user)
            invitar = true
          end
        end
      end
      PasswordsMailer.invitacion(user).deliver_later if invitar
      true
    rescue ActiveRecord::RecordInvalid => e
      if e.record.is_a?(User)
        e.record.errors.full_messages.each { |m| @colaborador.errors.add(:base, "Acceso: #{m}") }
      end
      false
    end
end

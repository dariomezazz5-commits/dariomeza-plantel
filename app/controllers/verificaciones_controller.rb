# Segundo paso del ingreso: código de 6 dígitos de la app autenticadora.
class VerificacionesController < ApplicationController
  layout "auth"
  allow_unauthenticated_access
  before_action :cargar_usuario
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Demasiados intentos. Vuelve a ingresar." }

  def new
  end

  def create
    if @user.otp_valido?(params[:codigo])
      session.delete(:verificacion)
      start_new_session_for @user
      RegistroAuditoria.registrar!("sesion.iniciada", "Inicio de sesión con verificación en dos pasos de #{@user.email_address}",
                                   user: @user, empresa: @user.empresa)
      redirect_to after_authentication_url
    else
      flash.now[:alert] = "El código no es válido o ya se usó. Revisa la hora de tu teléfono y prueba con el siguiente."
      render :new, status: :unprocessable_entity
    end
  end

  private
    def cargar_usuario
      datos = session[:verificacion]
      @user = User.find_by(id: datos["user_id"]) if datos && datos["expira"].to_i > Time.current.to_i
      redirect_to new_session_path, alert: "Vuelve a ingresar tu correo y contraseña." unless @user
    end
end

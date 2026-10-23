class SessionsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Demasiados intentos. Espera unos minutos y vuelve a intentar." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if user.dos_pasos_activo?
        session[:verificacion] = { "user_id" => user.id, "expira" => 5.minutes.from_now.to_i }
        redirect_to new_verificacion_path
      else
        iniciar_sesion(user)
      end
    else
      redirect_to new_session_path(email_address: params[:email_address]), alert: "Correo o contraseña incorrectos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Cerraste sesión."
  end

  private
    def iniciar_sesion(user)
      start_new_session_for user
      RegistroAuditoria.registrar!("sesion.iniciada", "Inicio de sesión de #{user.email_address}", user:, empresa: user.empresa)
      redirect_to after_authentication_url
    end
end

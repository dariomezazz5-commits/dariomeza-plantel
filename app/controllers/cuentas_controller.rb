# "Mi cuenta": verificación en dos pasos del usuario conectado.
class CuentasController < ApplicationController
  def show
    @user = usuario_actual
    unless @user.dos_pasos_activo?
      session[:otp_pendiente] ||= ROTP::Base32.random
      @secret = session[:otp_pendiente]
      uri = ROTP::TOTP.new(@secret, issuer: "Plantel").provisioning_uri(@user.email_address)
      @qr = RQRCode::QRCode.new(uri).as_svg(module_size: 4, standalone: true, use_path: true, viewbox: true)
    end
  end

  def activar_dos_pasos
    secret = session[:otp_pendiente]
    if secret && usuario_actual.otp_valido?(params[:codigo], secret:)
      usuario_actual.activar_dos_pasos!(secret)
      session.delete(:otp_pendiente)
      RegistroAuditoria.registrar!("sesion.dos_pasos_activada", "#{usuario_actual.email_address} activó la verificación en dos pasos", recurso: usuario_actual)
      redirect_to cuenta_path, notice: "Verificación en dos pasos activada."
    else
      redirect_to cuenta_path, alert: "El código no coincide. Escanea el código QR de nuevo y escribe el número que muestra la app."
    end
  end

  def desactivar_dos_pasos
    if usuario_actual.authenticate(params[:password])
      usuario_actual.desactivar_dos_pasos!
      RegistroAuditoria.registrar!("sesion.dos_pasos_desactivada", "#{usuario_actual.email_address} desactivó la verificación en dos pasos", recurso: usuario_actual)
      redirect_to cuenta_path, notice: "Verificación en dos pasos desactivada."
    else
      redirect_to cuenta_path, alert: "La contraseña no es correcta."
    end
  end
end

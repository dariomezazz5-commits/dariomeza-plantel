class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Restablece tu contraseña de Plantel", to: user.email_address
  end

  # Invitación: el mismo enlace de restablecimiento sirve para elegir la primera contraseña.
  def invitacion(user)
    @user = user
    mail subject: "#{user.empresa.nombre} te dio acceso a Plantel", to: user.email_address
  end
end

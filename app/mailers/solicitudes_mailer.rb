class SolicitudesMailer < ApplicationMailer
  # Al jefe directo (o a RR.HH. si no tiene) cuando llega una solicitud nueva.
  def nueva(solicitud)
    @solicitud = solicitud
    ActsAsTenant.with_tenant(solicitud.empresa) do
      destinatarios = aprobadores(solicitud)
      mail(to: destinatarios, subject: "Nueva solicitud de #{solicitud.colaborador.nombre_corto}: #{solicitud.tipo}") if destinatarios.any?
    end
  end

  # Al colaborador cuando su solicitud se aprueba o rechaza.
  def resuelta(solicitud)
    @solicitud = solicitud
    c = solicitud.colaborador
    mail(to: c.user&.email_address || c.email, subject: "Tu solicitud de #{solicitud.tipo.downcase} fue #{solicitud.estado.downcase}")
  end

  private
    def aprobadores(solicitud)
      jefe_user = solicitud.colaborador.jefe&.user
      return [ jefe_user.email_address ] if jefe_user
      solicitud.empresa.users.where(rol: "admin").where.not(colaborador_id: solicitud.colaborador_id).pluck(:email_address)
    end
end

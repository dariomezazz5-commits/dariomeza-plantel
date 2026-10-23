class AuditoriaController < ApplicationController
  POR_PAGINA = 50

  before_action :solo_admin!

  def index
    @accion = RegistroAuditoria::ACCIONES.key?(params[:accion]) ? params[:accion] : nil
    @pagina = [ params[:pagina].to_i, 1 ].max
    registros = RegistroAuditoria.includes(:user).order(created_at: :desc, id: :desc)
    registros = registros.where(accion: @accion) if @accion
    @registros = registros.offset((@pagina - 1) * POR_PAGINA).limit(POR_PAGINA + 1).to_a
    @hay_mas = @registros.size > POR_PAGINA
    @registros = @registros.first(POR_PAGINA)
  end
end

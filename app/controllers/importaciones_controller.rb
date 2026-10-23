class ImportacionesController < ApplicationController
  before_action :solo_admin!

  def new
  end

  def create
    archivo = params[:archivo]
    return redirect_to(new_importacion_path, alert: "Elige un archivo .xlsx o .csv.") unless archivo.respond_to?(:path)

    @resultado = ImportacionColaboradores.new(archivo.path, File.extname(archivo.original_filename)).ejecutar
    if @resultado.exitosa?
      RegistroAuditoria.registrar!("colaborador.importacion",
        "Importó #{archivo.original_filename}: #{@resultado.creados} nuevos, #{@resultado.actualizados} actualizados",
        cambios: { archivo: archivo.original_filename, creados: @resultado.creados, actualizados: @resultado.actualizados })
      redirect_to colaboradores_path, notice: "Importación lista: #{@resultado.creados} colaboradores nuevos y #{@resultado.actualizados} actualizados."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def plantilla
    send_data ImportacionColaboradores.plantilla_csv, filename: "plantilla_colaboradores.csv", type: "text/csv; charset=utf-8"
  end
end

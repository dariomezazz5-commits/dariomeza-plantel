require "csv"

# Importa colaboradores desde Excel (.xlsx) o CSV. Identifica a cada persona por su RUT:
# si ya existe la actualiza, si no la crea. Es todo o nada: si una fila tiene errores no se guarda ninguna.
class ImportacionColaboradores
  COLUMNAS = {
    "nombre" => :nombre, "rut" => :rut, "email" => :email, "correo" => :email, "cargo" => :cargo, "area" => :area,
    "sede" => :sede, "fecha_ingreso" => :ingreso, "ingreso" => :ingreso, "contrato" => :contrato, "estado" => :estado,
    "saldo_vacaciones" => :saldo_vacaciones, "rut_jefatura" => :rut_jefe
  }.freeze
  OBLIGATORIAS = %i[nombre rut email cargo area sede ingreso].freeze
  EJEMPLO = [ "Valentina Muñoz Díaz", "17.445.208-3", "vmunoz@empresa.cl", "Ingeniera de Procesos", "Operaciones",
              "Concepción", "13-01-2020", "Indefinido", "Activo", "17", "15.671.330-9" ].freeze

  Resultado = Struct.new(:creados, :actualizados, :errores) do
    def exitosa? = errores.empty?
  end

  def self.plantilla_csv
    encabezados = %w[nombre rut email cargo area sede fecha_ingreso contrato estado saldo_vacaciones rut_jefatura]
    "﻿" + CSV.generate(col_sep: ";") { |csv| csv << encabezados; csv << EJEMPLO }
  end

  def initialize(path, extension)
    @path, @extension = path, extension.to_s.downcase
  end

  def ejecutar
    resultado = Resultado.new(0, 0, [])
    filas = leer_filas(resultado)
    return resultado if resultado.errores.any?

    Colaborador.transaction do
      registros = filas.map do |numero, datos|
        c = Colaborador.find_or_initialize_by(rut: Rut.formatear(datos[:rut]))
        nuevo = c.new_record?
        c.assign_attributes(datos.except(:rut_jefe).compact_blank)
        c.contrato ||= "Indefinido"
        c.estado ||= "Activo"
        if c.save
          nuevo ? resultado.creados += 1 : resultado.actualizados += 1
        else
          resultado.errores << [ numero, c.errors.full_messages.to_sentence ]
        end
        [ numero, c, datos[:rut_jefe] ]
      end

      # Segunda pasada: la jefatura puede estar más abajo en el mismo archivo.
      registros.each do |numero, c, rut_jefe|
        next if rut_jefe.blank? || c.new_record?
        jefe = Colaborador.find_by(rut: Rut.formatear(rut_jefe))
        if jefe.nil?
          resultado.errores << [ numero, "La jefatura con RUT #{rut_jefe} no existe ni viene en el archivo" ]
        elsif !c.update(jefe:)
          resultado.errores << [ numero, c.errors.full_messages.to_sentence ]
        end
      end

      raise ActiveRecord::Rollback if resultado.errores.any?
    end
    resultado.creados = resultado.actualizados = 0 if resultado.errores.any?
    resultado
  end

  private
    def leer_filas(resultado)
      hoja = abrir_hoja
      encabezados = hoja.row(1).map { |h| COLUMNAS[normalizar(h)] }
      faltantes = OBLIGATORIAS - encabezados
      if faltantes.any?
        resultado.errores << [ 1, "Faltan columnas: #{faltantes.join(', ')}. Descarga la plantilla para ver el formato." ]
        return []
      end

      (2..hoja.last_row.to_i).filter_map do |n|
        valores = hoja.row(n)
        next if valores.all?(&:blank?)
        datos = encabezados.zip(valores).select(&:first).to_h.transform_values { |v| v.is_a?(String) ? v.strip : v }
        datos[:ingreso] = fecha(datos[:ingreso])
        datos[:saldo_vacaciones] = datos[:saldo_vacaciones].to_i if datos[:saldo_vacaciones].present?
        datos[:rut] = datos[:rut].to_s
        faltan = OBLIGATORIAS.select { |k| datos[k].blank? }
        if faltan.any?
          resultado.errores << [ n, "Faltan datos o tienen formato inválido: #{faltan.join(', ')}" ]
          next
        end
        [ n, datos ]
      end
    rescue StandardError => e
      resultado.errores << [ 0, "No pudimos leer el archivo (#{e.message}). Usa .xlsx o .csv." ]
      []
    end

    def abrir_hoja
      case @extension
      when ".xlsx" then Roo::Excelx.new(@path).sheet(0)
      when ".csv"
        contenido = File.read(@path, encoding: "bom|utf-8")
        separador = contenido.lines.first.to_s.count(";") > contenido.lines.first.to_s.count(",") ? ";" : ","
        filas = CSV.parse(contenido, col_sep: separador)
        Struct.new(:filas) { def row(n) = filas[n - 1] || []; def last_row = filas.size }.new(filas)
      else raise ArgumentError, "formato #{@extension.presence || 'desconocido'} no soportado"
      end
    end

    def normalizar(encabezado)
      encabezado.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase.strip.gsub(/[^a-z]+/, "_").delete_suffix("_")
    end

    def fecha(valor)
      case valor
      when Date then valor
      when nil, "" then nil
      else
        Date.strptime(valor.to_s, valor.to_s.include?("/") ? "%d/%m/%Y" : (valor.to_s =~ /\A\d{4}/ ? "%Y-%m-%d" : "%d-%m-%Y"))
      end
    rescue Date::Error
      nil
    end
end

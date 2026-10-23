# Datos de ejemplo tomados del prototipo "Plantel RRHH.dc.html".
JEFATURAS = { "Personas" => "Camila Rojas", "Operaciones" => "Benjamín Contreras", "Comercial" => "Tomás Araya",
              "Finanzas" => "Antonia Espinoza", "Tecnología" => "Felipe Rivera" }.freeze

PERSONAS = [
  [ 1, "Camila Rojas Fuentes", "Jefa de Personas", "Personas", "Santiago", "2019-03-04", "Indefinido", "14.238.917-3", 11, "Activo" ],
  [ 2, "Matías González Soto", "Analista de Remuneraciones", "Personas", "Santiago", "2022-07-11", "Indefinido", "18.902.114-6", 9, "Activo" ],
  [ 3, "Valentina Muñoz Díaz", "Ingeniera de Procesos", "Operaciones", "Concepción", "2020-01-13", "Indefinido", "17.445.208-K", 17, "Activo" ],
  [ 4, "Benjamín Contreras Silva", "Supervisor de Planta", "Operaciones", "Antofagasta", "2017-09-01", "Indefinido", "15.671.330-2", 22, "Activo" ],
  [ 5, "Francisca Morales Pérez", "Ejecutiva Comercial", "Comercial", "Santiago", "2023-02-06", "Indefinido", "19.337.802-1", 8, "Activo" ],
  [ 6, "Joaquín Sepúlveda Reyes", "Operador de Maquinaria", "Operaciones", "Antofagasta", "2025-05-17", "Plazo fijo", "20.118.459-4", 4, "Activo" ],
  [ 7, "Antonia Espinoza Castro", "Contadora", "Finanzas", "Santiago", "2018-11-05", "Indefinido", "16.004.775-8", 14, "Activo" ],
  [ 8, "Diego Torres Navarro", "Desarrollador Full Stack", "Tecnología", "Santiago", "2024-04-01", "Indefinido", "19.880.621-0", 15, "Activo" ],
  [ 9, "Isidora Vargas Herrera", "Diseñadora UX", "Tecnología", "Santiago", "2023-08-21", "Indefinido", "19.512.006-7", 12, "Activo" ],
  [ 10, "Tomás Araya Figueroa", "Jefe Comercial Zona Sur", "Comercial", "Concepción", "2016-06-13", "Indefinido", "13.995.402-5", 26, "Activo" ],
  [ 11, "Javiera Castillo Vega", "Prevencionista de Riesgos", "Operaciones", "Concepción", "2022-10-03", "Indefinido", "18.276.540-9", 10, "Activo" ],
  [ 12, "Sebastián Núñez Bravo", "Analista Financiero", "Finanzas", "Santiago", "2025-01-06", "Indefinido", "20.441.873-2", 6, "Activo" ],
  [ 13, "Catalina Gutiérrez Ortiz", "Ejecutiva de Postventa", "Comercial", "Santiago", "2024-09-09", "Plazo fijo", "20.067.315-1", 7, "Activo" ],
  [ 14, "Nicolás Fernández Lagos", "Mecánico de Mantención", "Operaciones", "Antofagasta", "2019-12-02", "Indefinido", "16.823.904-3", 13, "Licencia médica" ],
  [ 15, "Martina Pizarro Carrasco", "Reclutadora", "Personas", "Santiago", "2025-10-20", "Plazo fijo", "21.004.228-6", 0, "Activo" ],
  [ 16, "Felipe Rivera Alarcón", "Líder de Infraestructura", "Tecnología", "Santiago", "2020-08-24", "Indefinido", "17.209.661-4", 9, "Vacaciones" ]
].freeze

# [colaborador_id, tipo, día desde, día hasta (noviembre 2026), estado]
SOLICITUDES = [
  [ 3, "Vacaciones", 9, 13, "Pendiente" ],
  [ 8, "Vacaciones", 16, 27, "Pendiente" ],
  [ 6, "Permiso administrativo", 5, 5, "Pendiente" ],
  [ 9, "Vacaciones", 23, 27, "Pendiente" ],
  [ 2, "Permiso administrativo", 12, 12, "Aprobada" ],
  [ 14, "Licencia médica", 1, 8, "Aprobada" ],
  [ 7, "Vacaciones", 2, 6, "Aprobada" ],
  [ 10, "Vacaciones", 16, 20, "Aprobada" ],
  [ 5, "Vacaciones", 2, 4, "Rechazada" ],
  [ 16, "Vacaciones", 23, 30, "Aprobada" ]
].freeze

Solicitud.delete_all
Colaborador.delete_all
ProximoIngreso.delete_all

PERSONAS.each do |id, nombre, cargo, area, sede, ingreso, contrato, rut, vac, estado|
  partes = nombre.split
  email = (partes[0][0] + partes[1]).downcase.unicode_normalize(:nfd).gsub(/\p{Mn}/, "") + "@industriasandes.cl"
  Colaborador.create!(id:, nombre:, cargo:, area:, sede:, ingreso: Date.parse(ingreso), contrato:, rut:,
                      email:, saldo_vacaciones: vac, estado:,
                      jefatura: id == 1 ? "Gerencia General" : JEFATURAS.fetch(area))
end

SOLICITUDES.each do |colaborador_id, tipo, d1, d2, estado|
  Solicitud.create!(colaborador_id:, tipo:, desde: Date.new(2026, 11, d1), hasta: Date.new(2026, 11, d2), estado:,
                    resuelta_en: (estado == "Pendiente" ? nil : Time.current))
end

ProximoIngreso.create!(nombre: "Rocío Valenzuela", cargo: "Analista Contable", area: "Finanzas", fecha: Date.new(2026, 11, 3))
ProximoIngreso.create!(nombre: "Ignacio Salinas", cargo: "Operador de Grúa", area: "Operaciones", fecha: Date.new(2026, 11, 10))

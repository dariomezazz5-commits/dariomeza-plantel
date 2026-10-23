# Datos de ejemplo tomados del prototipo "Plantel RRHH.dc.html", más una segunda empresa
# para comprobar que los datos de cada empresa quedan aislados.
#
# Usuarios de prueba (contraseña: plantel-demo-2026):
#   camila@industriasandes.cl     Administradora de RR.HH.
#   benjamin@industriasandes.cl   Jefatura de Operaciones
#   valentina@industriasandes.cl  Colaboradora
#   admin@australsur.cl           Administrador de otra empresa
CLAVE_DEMO = "plantel-demo-2026"

PERSONAS = [
  [ 1, "Camila Rojas Fuentes", "Jefa de Personas", "Personas", "Santiago", "2019-03-04", "Indefinido", "14.238.917-3", 11, "Activo", nil ],
  [ 2, "Matías González Soto", "Analista de Remuneraciones", "Personas", "Santiago", "2022-07-11", "Indefinido", "18.902.114-6", 9, "Activo", 1 ],
  [ 3, "Valentina Muñoz Díaz", "Ingeniera de Procesos", "Operaciones", "Concepción", "2020-01-13", "Indefinido", "17.445.208-K", 17, "Activo", 4 ],
  [ 4, "Benjamín Contreras Silva", "Supervisor de Planta", "Operaciones", "Antofagasta", "2017-09-01", "Indefinido", "15.671.330-2", 22, "Activo", nil ],
  [ 5, "Francisca Morales Pérez", "Ejecutiva Comercial", "Comercial", "Santiago", "2023-02-06", "Indefinido", "19.337.802-1", 8, "Activo", 10 ],
  [ 6, "Joaquín Sepúlveda Reyes", "Operador de Maquinaria", "Operaciones", "Antofagasta", "2025-05-17", "Plazo fijo", "20.118.459-4", 4, "Activo", 4 ],
  [ 7, "Antonia Espinoza Castro", "Contadora", "Finanzas", "Santiago", "2018-11-05", "Indefinido", "16.004.775-8", 14, "Activo", nil ],
  [ 8, "Diego Torres Navarro", "Desarrollador Full Stack", "Tecnología", "Santiago", "2024-04-01", "Indefinido", "19.880.621-0", 15, "Activo", 16 ],
  [ 9, "Isidora Vargas Herrera", "Diseñadora UX", "Tecnología", "Santiago", "2023-08-21", "Indefinido", "19.512.006-7", 12, "Activo", 16 ],
  [ 10, "Tomás Araya Figueroa", "Jefe Comercial Zona Sur", "Comercial", "Concepción", "2016-06-13", "Indefinido", "13.995.402-5", 26, "Activo", nil ],
  [ 11, "Javiera Castillo Vega", "Prevencionista de Riesgos", "Operaciones", "Concepción", "2022-10-03", "Indefinido", "18.276.540-9", 10, "Activo", 4 ],
  [ 12, "Sebastián Núñez Bravo", "Analista Financiero", "Finanzas", "Santiago", "2025-01-06", "Indefinido", "20.441.873-2", 6, "Activo", 7 ],
  [ 13, "Catalina Gutiérrez Ortiz", "Ejecutiva de Postventa", "Comercial", "Santiago", "2024-09-09", "Plazo fijo", "20.067.315-1", 7, "Activo", 10 ],
  [ 14, "Nicolás Fernández Lagos", "Mecánico de Mantención", "Operaciones", "Antofagasta", "2019-12-02", "Indefinido", "16.823.904-3", 13, "Licencia médica", 4 ],
  [ 15, "Martina Pizarro Carrasco", "Reclutadora", "Personas", "Santiago", "2025-10-20", "Plazo fijo", "21.004.228-6", 0, "Activo", 1 ],
  [ 16, "Felipe Rivera Alarcón", "Líder de Infraestructura", "Tecnología", "Santiago", "2020-08-24", "Indefinido", "17.209.661-4", 9, "Vacaciones", nil ]
].freeze

# [n° de persona, tipo, día desde, día hasta (noviembre 2026), estado]
SOLICITUDES = [
  [ 3, "Vacaciones", 9, 13, "Pendiente" ], [ 8, "Vacaciones", 16, 27, "Pendiente" ],
  [ 6, "Permiso administrativo", 5, 5, "Pendiente" ], [ 9, "Vacaciones", 23, 27, "Pendiente" ],
  [ 2, "Permiso administrativo", 12, 12, "Aprobada" ], [ 14, "Licencia médica", 1, 8, "Aprobada" ],
  [ 7, "Vacaciones", 2, 6, "Aprobada" ], [ 10, "Vacaciones", 16, 20, "Aprobada" ],
  [ 5, "Vacaciones", 2, 4, "Rechazada" ], [ 16, "Vacaciones", 23, 30, "Aprobada" ]
].freeze

# Los RUT del prototipo son ficticios: se corrige su dígito verificador para que pasen la validación.
def rut_valido(rut)
  cuerpo = Rut.limpiar(rut)[0..-2]
  Rut.formatear(cuerpo + Rut.dv(cuerpo))
end

def email_para(nombre, dominio)
  partes = nombre.split
  (partes[0][0] + partes[1]).downcase.unicode_normalize(:nfd).gsub(/\p{Mn}/, "") + "@#{dominio}"
end

ActsAsTenant.without_tenant do
  [ RegistroAuditoria, Session, Solicitud, User, ProximoIngreso ].each(&:delete_all)
  Colaborador.update_all(jefe_id: nil)
  Colaborador.delete_all
  Empresa.delete_all
end

andes = Empresa.create!(nombre: "Industrias Andes SpA", rut: "76.123.456-0")
ActsAsTenant.with_tenant(andes) do
  por_numero = {}
  PERSONAS.each do |n, nombre, cargo, area, sede, ingreso, contrato, rut, vac, estado, _jefe|
    por_numero[n] = Colaborador.create!(nombre:, cargo:, area:, sede:, ingreso: Date.parse(ingreso), contrato:, rut: rut_valido(rut),
                                        email: email_para(nombre, "industriasandes.cl"), saldo_vacaciones: vac, estado:)
  end
  PERSONAS.each { |n, *, jefe| por_numero[n].update!(jefe: por_numero[jefe]) if jefe }

  usuarios = {
    "camila@industriasandes.cl" => [ 1, "admin" ],
    "benjamin@industriasandes.cl" => [ 4, "jefatura" ],
    "felipe@industriasandes.cl" => [ 16, "jefatura" ],
    "tomas@industriasandes.cl" => [ 10, "jefatura" ],
    "valentina@industriasandes.cl" => [ 3, "colaborador" ]
  }
  usuarios.each do |email, (n, rol)|
    User.create!(empresa: andes, colaborador: por_numero[n], email_address: email, rol:, password: CLAVE_DEMO)
  end

  # Las solicitudes de ejemplo se crean sin enviar correos.
  Solicitud.skip_callback(:commit, :after, :notificar_creacion)
  SOLICITUDES.each do |n, tipo, d1, d2, estado|
    Solicitud.create!(colaborador: por_numero[n], tipo:, desde: Date.new(2026, 11, d1), hasta: Date.new(2026, 11, d2), estado:,
                      resuelta_en: (estado == "Pendiente" ? nil : Time.current))
  end
  Solicitud.set_callback(:commit, :after, :notificar_creacion, on: :create)

  ProximoIngreso.create!(nombre: "Rocío Valenzuela", cargo: "Analista Contable", area: "Finanzas", fecha: Date.new(2026, 11, 3))
  ProximoIngreso.create!(nombre: "Ignacio Salinas", cargo: "Operador de Grúa", area: "Operaciones", fecha: Date.new(2026, 11, 10))
end

austral = Empresa.create!(nombre: "Pesquera Austral Sur Ltda.", rut: "77.654.321-7")
ActsAsTenant.with_tenant(austral) do
  jefa = Colaborador.create!(nombre: "Rosa Aguilar Paredes", cargo: "Gerenta de Personas", area: "Personas", sede: "Puerto Montt",
                             ingreso: Date.new(2018, 4, 2), contrato: "Indefinido", rut: "12.345.678-5", email: "raguilar@australsur.cl", saldo_vacaciones: 15)
  Colaborador.create!(nombre: "Pedro Cárcamo Ojeda", cargo: "Jefe de Planta", area: "Producción", sede: "Puerto Montt", jefe: jefa,
                      ingreso: Date.new(2021, 3, 1), contrato: "Indefinido", rut: "11.111.111-1", email: "pcarcamo@australsur.cl", saldo_vacaciones: 12)
  User.create!(empresa: austral, colaborador: jefa, email_address: "admin@australsur.cl", rol: "admin", password: CLAVE_DEMO)
end

puts "Listo: #{Empresa.count} empresas. Ingresa con camila@industriasandes.cl / #{CLAVE_DEMO}"

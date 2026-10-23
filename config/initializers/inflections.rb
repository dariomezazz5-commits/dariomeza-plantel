# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "colaborador", "colaboradores"
  inflect.irregular "solicitud", "solicitudes"
  inflect.irregular "proximo_ingreso", "proximos_ingresos"
end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "empresa", "empresas"
  inflect.irregular "registro_auditoria", "registros_auditoria"
  inflect.irregular "importacion", "importaciones"
  inflect.irregular "verificacion", "verificaciones"
  inflect.irregular "cuenta", "cuentas"
end

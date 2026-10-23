module ApplicationHelper
  # Íconos Lucide (stroke 1.5).
  ICONOS = {
    house: '<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
    users: '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
    calendar: '<path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/>',
    search: '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
    plus: '<path d="M5 12h14"/><path d="M12 5v14"/>',
    x: '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>'
  }.freeze

  def icono(nombre, size: 18, **opts)
    tag.svg(ICONOS.fetch(nombre).html_safe, width: size, height: size, viewBox: "0 0 24 24", fill: "none",
            stroke: "currentColor", "stroke-width": 1.5, "stroke-linecap": "round", "stroke-linejoin": "round",
            "aria-hidden": true, **opts)
  end

  # Marcas de registro "+" en las esquinas de los objetos .blueprint
  def esquinas
    safe_join(%w[tl tr bl br].map { |c| tag.i(class: "corner #{c}") })
  end

  def avatar(iniciales, size: 30)
    tag.span(iniciales, class: "avatar avatar-#{size}")
  end

  def nav_item(label, path, icon, activo:, &extra)
    link_to path, class: [ "nav-item", ("is-active" if activo) ], "aria-current": (activo ? "page" : nil) do
      safe_join([ icono(icon), tag.span(label, class: "nav-label"), (capture(&extra) if extra) ])
    end
  end

  def fecha_larga(fecha = Date.current) = l(fecha, format: :largo).upcase_first
  def fecha_corta(fecha) = l(fecha, format: :corto)
  def dia_mes(fecha) = "#{fecha.day} #{l(fecha, format: '%b')}"

  # "9–13 nov", "5 nov", "28 oct–3 nov"
  def rango_fechas(desde, hasta)
    return dia_mes(desde) if desde == hasta
    return "#{desde.day}–#{dia_mes(hasta)}" if desde.month == hasta.month && desde.year == hasta.year
    "#{dia_mes(desde)}–#{dia_mes(hasta)}"
  end

  def saludo(hora = Time.current.hour)
    hora < 12 ? "Buenos días" : hora < 20 ? "Buenas tardes" : "Buenas noches"
  end

  def estado_colaborador_class(estado) = estado == "Activo" ? "tag tag-neutral" : "tag tag-accent"

  def estado_solicitud_class(estado)
    { "Pendiente" => "tag tag-outline", "Aprobada" => "tag tag-accent" }.fetch(estado, "tag tag-neutral")
  end

  # "noviembre" si todas las fechas caen en un mismo mes
  def nota_mes(fechas, prefijo: nil, vacio: "—")
    meses = fechas.map { |f| f.beginning_of_month }.uniq
    return vacio if meses.empty?
    return [ prefijo, l(meses.first, format: "%B") ].compact.join(" ") if meses.one?
    "varios meses"
  end
end

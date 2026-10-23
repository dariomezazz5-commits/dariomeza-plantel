# Plantel · Gestión de personas (Rails 8)

Implementación del handoff de diseño "Plantel RRHH" con las variantes elegidas:
**1a Inicio – Resumen**, **2a Colaboradores – Tabla**, **3a Ausencias – Lista de aprobación**,
más la **ficha lateral de colaborador** y el diálogo **Nueva solicitud**.

Stack: Rails 8.1, SQLite, Propshaft, Importmap, Turbo y Stimulus (sin build de JS).

## Probar en GitHub Codespaces

En el repositorio: **Code → Codespaces → Create codespace on main**. El contenedor instala las gemas,
crea la base con los datos de ejemplo y levanta el servidor; cuando aparezca el aviso del puerto 3000,
haz clic en **Open in Browser**.

Si no ves la app:
- La primera creación tarda 3–5 minutos; espera a que la terminal muestre `Listening on http://0.0.0.0:3000`.
- Si el servidor no partió solo, en la terminal: `bin/rails server -b 0.0.0.0`.
- Abre la app desde la pestaña **PORTS** → puerto 3000 → ícono 🌐 (la URL termina en `.app.github.dev`).
  No uses `localhost:3000` en tu navegador: la app corre en la máquina de GitHub, no en tu computador.

## Puesta en marcha local

```bash
bundle install
bin/rails db:prepare db:seed   # carga los datos de ejemplo del prototipo
bin/rails server               # http://localhost:3000
bin/rails test
```

## Mapa del código

| Pieza del diseño | Archivo |
|---|---|
| Layout + sidebar + badge de pendientes | `app/views/layouts/application.html.erb` |
| 1a Inicio – Resumen | `app/controllers/inicio_controller.rb`, `app/views/inicio/show.html.erb` |
| 2a Colaboradores – Tabla (búsqueda + chips por turbo_stream) | `colaboradores_controller.rb`, `app/views/colaboradores/*` |
| Ficha lateral (turbo-frame `drawer`) | `app/views/colaboradores/show.html.erb` |
| 3a Ausencias – Lista de aprobación | `solicitudes_controller.rb`, `app/views/solicitudes/index.html.erb` |
| Diálogo Nueva solicitud (turbo-frame `modal`) | `app/views/solicitudes/_dialogo.html.erb` |
| Días hábiles (lun–vie menos feriados) | `app/models/dias_habiles.rb`, `config/feriados.yml` |
| Tokens y clases del sistema Industry | `app/assets/stylesheets/industry.css` |
| Estilos propios de la app | `app/assets/stylesheets/plantel.css` |
| JS (Stimulus) | `app/javascript/controllers/{filtro,fila,overlay,solicitud_form}_controller.js` |

## Comportamiento

- Aprobar / Rechazar / Deshacer son `PATCH` que redirigen a la misma página; Turbo hace *morph*,
  así que badge, KPIs y pestañas se actualizan sin perder el scroll.
- "Deshacer" aparece solo en solicitudes resueltas durante la sesión actual (como en el prototipo).
- Al aprobar vacaciones se descuentan los días hábiles del saldo del colaborador; deshacer los devuelve.
- La ficha se puede enlazar directamente con `?ficha=ID`. Se cierra con Esc, con la ✕ o con un clic fuera.
- Nueva solicitud: resumen en vivo ("2–6 nov · 5 días hábiles") y botón deshabilitado hasta que el formulario es válido;
  el servidor vuelve a validar. Las fechas ya no están limitadas a noviembre de 2026.

## Pendiente para producción

- Autenticación y permisos (`usuario_actual` en `ApplicationController` es un placeholder).
- Revisar `config/feriados.yml` cada año.
- `industry.css` se reconstruyó a partir de los tokens del README del handoff, porque el `_ds/.../styles.css`
  original no venía en el paquete. Si lo tienes, reemplázalo: las clases tienen los mismos nombres.

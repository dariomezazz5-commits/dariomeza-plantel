# Plantel · Gestión de personas (Rails 8)

Plataforma de RR.HH. para empresas chilenas: directorio de colaboradores, ficha, solicitudes de ausencia
con flujo de aprobación, varias empresas aisladas entre sí, roles, verificación en dos pasos y auditoría.

Stack: Rails 8.1, PostgreSQL, Propshaft, Importmap, Turbo y Stimulus (sin build de JS).

## Probar en GitHub Codespaces

En el repositorio: **Code → Codespaces → Create codespace** (en la rama que quieras probar). El contenedor levanta
PostgreSQL, instala las gemas, carga los datos de ejemplo y arranca el servidor. Cuando aparezca el aviso del
puerto 3000, haz clic en **Open in Browser** (o pestaña **PORTS** → puerto 3000 → 🌐).

Si el servidor no partió solo: `bin/rails server -b 0.0.0.0`. No uses `localhost:3000` en tu navegador:
la app corre en la máquina de GitHub.

### Usuarios de prueba

Contraseña de todos: `plantel-demo-2026`

| Correo | Rol | Qué ve |
|---|---|---|
| camila@industriasandes.cl | Administradora de RR.HH. | Toda la empresa, alta/edición, importación, auditoría |
| benjamin@industriasandes.cl | Jefatura (Operaciones) | Su equipo directo; aprueba sus solicitudes |
| valentina@industriasandes.cl | Colaboradora | Su ficha y sus ausencias |
| admin@australsur.cl | Admin de **otra empresa** | Solo los datos de Pesquera Austral Sur |

Los correos no se envían en desarrollo: se ven en **/letter_opener**.

## Puesta en marcha local

Requiere Ruby 3.3+ y PostgreSQL 14+ (usuario/clave por defecto `plantel`/`plantel`; se cambian con
`DB_HOST`, `DB_USER`, `DB_PASSWORD`).

```bash
bundle install
bin/rails db:prepare db:seed
bin/rails server
bin/rails test
```

## Qué hace cada pieza

| Función | Dónde |
|---|---|
| Ingreso, recuperación de contraseña, sesiones | `SessionsController`, `PasswordsController`, `concerns/authentication.rb` (generador de Rails 8) |
| Verificación en dos pasos (TOTP, código QR) | `CuentasController` (activar/desactivar), `VerificacionesController` (paso 2 del ingreso), `User#otp_valido?` |
| Roles y permisos | `User#colaboradores_visibles`, `#solicitudes_aprobables`, `#puede_aprobar?` |
| Varias empresas | gema `acts_as_tenant`: todo modelo con `acts_as_tenant :empresa` se filtra por la empresa del usuario conectado |
| Alta/edición de colaboradores + acceso e invitación | `ColaboradoresController`, `colaboradores/_form` |
| Importación desde Excel/CSV | `ImportacionColaboradores`, `ImportacionesController` (plantilla en `/importaciones/plantilla`) |
| Correos de aprobación | `SolicitudesMailer#nueva` (a la jefatura o RR.HH.), `#resuelta` (al colaborador) |
| Auditoría | `RegistroAuditoria` (inmutable), pantalla `/auditoria` |
| RUT chileno | `Rut` (dígito verificador módulo 11) |
| Días hábiles con feriados | `DiasHabiles`, `config/feriados.yml` |

### Roles

- **Colaborador**: ve su ficha y sus ausencias; pide ausencias solo para sí.
- **Jefatura**: además ve a su equipo directo (`jefe_id`) y aprueba o rechaza sus solicitudes.
- **Administrador de RR.HH.**: ve y administra toda su empresa. Nadie aprueba sus propias solicitudes.

## Producción

Variables de entorno: `DATABASE_URL`, `RAILS_MASTER_KEY`, `APP_HOST` (dominio público, para los enlaces de los correos),
`SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `MAIL_FROM`.

Pendiente antes de clientes reales: cola de trabajos persistente para los correos (hoy usan el adaptador
`:async`, en memoria; se recomienda Solid Queue), registro de nuevas empresas, y revisar `config/feriados.yml` cada año.

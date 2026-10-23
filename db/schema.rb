# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_23_000007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "colaboradores", force: :cascade do |t|
    t.bigint "empresa_id", null: false
    t.bigint "jefe_id"
    t.string "nombre", null: false
    t.string "cargo", null: false
    t.string "area", null: false
    t.string "sede", null: false
    t.date "ingreso", null: false
    t.string "contrato", null: false
    t.string "rut", null: false
    t.string "email", null: false
    t.integer "saldo_vacaciones", default: 0, null: false
    t.string "estado", default: "Activo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["empresa_id", "rut"], name: "index_colaboradores_on_empresa_id_and_rut", unique: true
    t.index ["empresa_id"], name: "index_colaboradores_on_empresa_id"
    t.index ["jefe_id"], name: "index_colaboradores_on_jefe_id"
  end

  create_table "empresas", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "rut", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rut"], name: "index_empresas_on_rut", unique: true
  end

  create_table "proximos_ingresos", force: :cascade do |t|
    t.bigint "empresa_id", null: false
    t.string "nombre", null: false
    t.string "cargo", null: false
    t.string "area", null: false
    t.date "fecha", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["empresa_id"], name: "index_proximos_ingresos_on_empresa_id"
  end

  create_table "registros_auditoria", force: :cascade do |t|
    t.bigint "empresa_id", null: false
    t.bigint "user_id"
    t.string "accion", null: false
    t.string "recurso_type"
    t.bigint "recurso_id"
    t.string "descripcion", null: false
    t.jsonb "cambios", default: {}, null: false
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.index ["empresa_id", "created_at"], name: "index_registros_auditoria_on_empresa_id_and_created_at"
    t.index ["empresa_id"], name: "index_registros_auditoria_on_empresa_id"
    t.index ["recurso_type", "recurso_id"], name: "index_registros_auditoria_on_recurso"
    t.index ["user_id"], name: "index_registros_auditoria_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solicitudes", force: :cascade do |t|
    t.bigint "empresa_id", null: false
    t.bigint "colaborador_id", null: false
    t.bigint "creada_por_id"
    t.bigint "resuelta_por_id"
    t.string "tipo", null: false
    t.date "desde", null: false
    t.date "hasta", null: false
    t.string "estado", default: "Pendiente", null: false
    t.datetime "resuelta_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["colaborador_id"], name: "index_solicitudes_on_colaborador_id"
    t.index ["creada_por_id"], name: "index_solicitudes_on_creada_por_id"
    t.index ["empresa_id", "estado"], name: "index_solicitudes_on_empresa_id_and_estado"
    t.index ["empresa_id"], name: "index_solicitudes_on_empresa_id"
    t.index ["resuelta_por_id"], name: "index_solicitudes_on_resuelta_por_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "empresa_id", null: false
    t.bigint "colaborador_id"
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "rol", default: "colaborador", null: false
    t.string "otp_secret"
    t.datetime "otp_activado_en"
    t.datetime "otp_ultimo_uso_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["colaborador_id"], name: "index_users_on_colaborador_id", unique: true
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["empresa_id"], name: "index_users_on_empresa_id"
  end

  add_foreign_key "colaboradores", "colaboradores", column: "jefe_id"
  add_foreign_key "colaboradores", "empresas"
  add_foreign_key "proximos_ingresos", "empresas"
  add_foreign_key "registros_auditoria", "empresas"
  add_foreign_key "registros_auditoria", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "solicitudes", "colaboradores"
  add_foreign_key "solicitudes", "empresas"
  add_foreign_key "solicitudes", "users", column: "creada_por_id"
  add_foreign_key "solicitudes", "users", column: "resuelta_por_id"
  add_foreign_key "users", "colaboradores"
  add_foreign_key "users", "empresas"
end

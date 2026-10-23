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

ActiveRecord::Schema[8.1].define(version: 2026_10_23_000003) do
  create_table "colaboradores", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "cargo", null: false
    t.string "area", null: false
    t.string "sede", null: false
    t.date "ingreso", null: false
    t.string "contrato", null: false
    t.string "rut", null: false
    t.string "email", null: false
    t.string "jefatura"
    t.integer "saldo_vacaciones", default: 0, null: false
    t.string "estado", default: "Activo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rut"], name: "index_colaboradores_on_rut", unique: true
  end

  create_table "proximos_ingresos", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "cargo", null: false
    t.string "area", null: false
    t.date "fecha", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solicitudes", force: :cascade do |t|
    t.integer "colaborador_id", null: false
    t.string "tipo", null: false
    t.date "desde", null: false
    t.date "hasta", null: false
    t.string "estado", default: "Pendiente", null: false
    t.datetime "resuelta_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["colaborador_id"], name: "index_solicitudes_on_colaborador_id"
    t.index ["estado"], name: "index_solicitudes_on_estado"
  end

  add_foreign_key "solicitudes", "colaboradores"
end

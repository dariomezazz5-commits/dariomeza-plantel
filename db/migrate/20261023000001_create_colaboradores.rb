class CreateColaboradores < ActiveRecord::Migration[8.1]
  def change
    create_table :colaboradores do |t|
      t.string :nombre, null: false
      t.string :cargo, null: false
      t.string :area, null: false
      t.string :sede, null: false
      t.date :ingreso, null: false
      t.string :contrato, null: false
      t.string :rut, null: false, index: { unique: true }
      t.string :email, null: false
      t.string :jefatura
      t.integer :saldo_vacaciones, null: false, default: 0
      t.string :estado, null: false, default: "Activo"
      t.timestamps
    end
  end
end

class CreateColaboradores < ActiveRecord::Migration[8.1]
  def change
    create_table :colaboradores do |t|
      t.references :empresa, null: false, foreign_key: true
      t.references :jefe, foreign_key: { to_table: :colaboradores }
      t.string :nombre, null: false
      t.string :cargo, null: false
      t.string :area, null: false
      t.string :sede, null: false
      t.date :ingreso, null: false
      t.string :contrato, null: false
      t.string :rut, null: false
      t.string :email, null: false
      t.integer :saldo_vacaciones, null: false, default: 0
      t.string :estado, null: false, default: "Activo"
      t.timestamps
    end
    add_index :colaboradores, %i[empresa_id rut], unique: true
  end
end

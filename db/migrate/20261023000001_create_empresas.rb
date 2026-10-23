class CreateEmpresas < ActiveRecord::Migration[8.1]
  def change
    create_table :empresas do |t|
      t.string :nombre, null: false
      t.string :rut, null: false, index: { unique: true }
      t.timestamps
    end
  end
end

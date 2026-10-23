class CreateProximosIngresos < ActiveRecord::Migration[8.1]
  def change
    create_table :proximos_ingresos do |t|
      t.string :nombre, null: false
      t.string :cargo, null: false
      t.string :area, null: false
      t.date :fecha, null: false
      t.timestamps
    end
  end
end

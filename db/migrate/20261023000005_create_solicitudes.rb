class CreateSolicitudes < ActiveRecord::Migration[8.1]
  def change
    create_table :solicitudes do |t|
      t.references :empresa, null: false, foreign_key: true
      t.references :colaborador, null: false, foreign_key: true
      t.references :creada_por, foreign_key: { to_table: :users }
      t.references :resuelta_por, foreign_key: { to_table: :users }
      t.string :tipo, null: false
      t.date :desde, null: false
      t.date :hasta, null: false
      t.string :estado, null: false, default: "Pendiente"
      t.datetime :resuelta_en
      t.timestamps
    end
    add_index :solicitudes, %i[empresa_id estado]
  end
end

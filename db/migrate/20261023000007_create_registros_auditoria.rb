class CreateRegistrosAuditoria < ActiveRecord::Migration[8.1]
  def change
    create_table :registros_auditoria do |t|
      t.references :empresa, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :accion, null: false
      t.references :recurso, polymorphic: true
      t.string :descripcion, null: false
      t.jsonb :cambios, null: false, default: {}
      t.string :ip_address
      t.datetime :created_at, null: false
    end
    add_index :registros_auditoria, %i[empresa_id created_at]
  end
end

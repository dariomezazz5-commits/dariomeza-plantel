class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :empresa, null: false, foreign_key: true
      t.references :colaborador, foreign_key: true, index: { unique: true }
      t.string :email_address, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :rol, null: false, default: "colaborador"
      t.string :otp_secret
      t.datetime :otp_activado_en
      t.datetime :otp_ultimo_uso_en
      t.timestamps
    end
  end
end

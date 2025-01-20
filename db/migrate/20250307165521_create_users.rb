class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :auth0_id, null: false
      t.integer :status, null: false
      t.references :company, null: false, foreign_key: true
      t.timestamps
    end
  end
end

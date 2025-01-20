class CreateCompany < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :database_name, null: false
      t.timestamps
    end
  end
end

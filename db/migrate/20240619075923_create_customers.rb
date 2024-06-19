class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.string :phone
      t.string :fax
      t.string :email
      t.references :support_rep, foreign_key: { to_table: :employees }

      t.timestamps
    end
  end
end

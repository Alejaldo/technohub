class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :last_name
      t.string :first_name
      t.string :title
      t.references :reports_to, foreign_key: { to_table: :employees }
      t.timestamp :birth_date
      t.timestamp :hire_date
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.string :phone
      t.string :fax
      t.string :email

      t.timestamps
    end
  end
end

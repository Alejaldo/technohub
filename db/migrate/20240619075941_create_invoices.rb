class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :customer, null: false, foreign_key: true
      t.timestamp :invoice_date
      t.string :billing_address
      t.string :billing_city
      t.string :billing_state
      t.string :billing_country
      t.string :billing_postal_code
      t.decimal :total

      t.timestamps
    end
  end
end

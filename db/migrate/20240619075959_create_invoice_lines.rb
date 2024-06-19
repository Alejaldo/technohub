class CreateInvoiceLines < ActiveRecord::Migration[7.1]
  def change
    create_table :invoice_lines do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.decimal :unit_price
      t.integer :quantity

      t.timestamps
    end
  end
end

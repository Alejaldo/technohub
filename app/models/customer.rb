class Customer < ApplicationRecord
  has_many :invoices, dependent: :destroy
  belongs_to :support_rep, class_name: 'Employee', optional: true
end

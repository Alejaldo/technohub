class Employee < ApplicationRecord
  has_many :customers, foreign_key: :support_rep_id, dependent: :nullify
  has_many :subordinates, class_name: "Employee", foreign_key: :reports_to_id, dependent: :nullify
  belongs_to :manager, class_name: "Employee", optional: true, foreign_key: :reports_to_id
end

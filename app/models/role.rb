class Role < ApplicationRecord
  belongs_to :company
  has_many :users
  has_many :permissions, dependent: :destroy
end

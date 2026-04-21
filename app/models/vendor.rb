class Vendor < ApplicationRecord
  belongs_to :user

  has_many :stocks, dependent: :restrict_with_error

  # has_many :product_vendors, dependent: :restrict_with_error
  # has_many :products, through: :product_vendors

  validates :name, presence: true
  validates :email, uniqueness: { scope: :user_id }, allow_blank: true 
  
  validates :phone, 
            presence: true, 
            format: { with: /\A\d{10}\z/, message: "must be exactly 10 digits" }, 
            uniqueness: { scope: :user_id }
end

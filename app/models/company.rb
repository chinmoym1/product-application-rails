class Company < ApplicationRecord
  has_many :users
  has_many :roles
  has_many :products
  has_many :vendors
  has_many :customers
  has_many :orders
  has_many :stocks

  before_validation :strip_space

  validates :name, presence: true, 
                   uniqueness: { 
                     case_sensitive: false, 
                     message: "is already registered. Please ask your company admin to send you an invitation link." 
                   }
  
  private

  def strip_space
    self.name = self.name.strip unless self.name.nil?
  end
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :vendors, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :stocks, through: :products, source: :stocks

  has_one_attached :avatar
  attr_accessor :remove_avatar

  validate :acceptable_avatar

  after_save :purge_avatar, if: -> { remove_avatar == '1' || remove_avatar == true }

  belongs_to :company
  belongs_to :role, optional: true

  accepts_nested_attributes_for :company
  
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  def purge_avatar
    avatar.purge_later
    self.remove_avatar = nil
  end

  def acceptable_avatar
    return unless avatar.attached?

    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif"]
    
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, "must be a JPG, JPEG, PNG, or GIF")
    end
  end
end

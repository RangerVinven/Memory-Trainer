class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pao_numbers, dependent: :destroy
  has_many :pao_digits, dependent: :destroy
  has_many :pao_cards, dependent: :destroy
  has_many :memory_palaces, dependent: :destroy
  has_many :training_sessions, dependent: :destroy
end

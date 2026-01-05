class PaoNumber < ApplicationRecord
  belongs_to :user

  validates :number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 99 }
  validates :number, uniqueness: { scope: :user_id }
end
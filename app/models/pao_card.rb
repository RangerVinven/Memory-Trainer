class PaoCard < ApplicationRecord
  belongs_to :user

  enum :suit, [:spades, :hearts, :diamonds, :clubs]
  enum :rank, [:ace, :two, :three, :four, :five, :six, :seven, :eight, :nine, :ten, :jack, :queen, :king]

  validates :suit, presence: true
  validates :rank, presence: true
  validates :rank, uniqueness: { scope: [:user_id, :suit] }
end
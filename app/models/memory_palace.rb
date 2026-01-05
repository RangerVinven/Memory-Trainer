class MemoryPalace < ApplicationRecord
  belongs_to :user
  has_many :loci, -> { order(position: :asc) }, dependent: :destroy
end
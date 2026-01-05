class Locus < ApplicationRecord
  belongs_to :memory_palace
  acts_as_list scope: :memory_palace
end
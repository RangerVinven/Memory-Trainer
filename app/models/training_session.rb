class TrainingSession < ApplicationRecord
  belongs_to :user
  
  enum :status, [:memorizing, :recalling, :completed], default: :memorizing

  validates :training_type, presence: true
end
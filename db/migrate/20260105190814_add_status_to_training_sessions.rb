class AddStatusToTrainingSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :training_sessions, :status, :integer
  end
end

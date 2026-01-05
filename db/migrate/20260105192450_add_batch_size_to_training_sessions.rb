class AddBatchSizeToTrainingSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :training_sessions, :batch_size, :integer
  end
end

class CreateTrainingSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :training_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :training_type
      t.text :training_data
      t.text :recall_data
      t.integer :duration_seconds
      t.integer :item_count
      t.float :accuracy_percentage
      t.datetime :completed_at

      t.timestamps
    end
  end
end

class CreatePaoNumbers < ActiveRecord::Migration[8.1]
  def change
    create_table :pao_numbers do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :number
      t.string :person
      t.string :action
      t.string :object

      t.timestamps
    end
    add_index :pao_numbers, [:user_id, :number], unique: true
  end
end

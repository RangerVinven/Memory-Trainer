class CreatePaoCards < ActiveRecord::Migration[8.1]
  def change
    create_table :pao_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :suit
      t.integer :rank
      t.string :person
      t.string :action
      t.string :object

      t.timestamps
    end
    add_index :pao_cards, [:user_id, :suit, :rank], unique: true
  end
end

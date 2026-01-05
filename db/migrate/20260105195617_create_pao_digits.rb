class CreatePaoDigits < ActiveRecord::Migration[8.1]
  def change
    create_table :pao_digits do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :number
      t.string :person
      t.string :action
      t.string :object

      t.timestamps
    end
  end
end

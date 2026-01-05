class CreateLoci < ActiveRecord::Migration[8.1]
  def change
    create_table :loci do |t|
      t.references :memory_palace, null: false, foreign_key: true
      t.string :description
      t.integer :position

      t.timestamps
    end
  end
end

class AddNameToLoci < ActiveRecord::Migration[8.1]
  def change
    add_column :loci, :name, :string
  end
end

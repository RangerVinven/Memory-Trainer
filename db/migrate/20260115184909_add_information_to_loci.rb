class AddInformationToLoci < ActiveRecord::Migration[8.1]
  def change
    add_column :loci, :information, :string
  end
end

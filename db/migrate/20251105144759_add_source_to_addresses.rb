class AddSourceToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :source, :string, null: true
  end

  def down
    remove_column :addresses, :source, :string, null: true
  end
end

class RemovePoboxnumberFromAddresses < ActiveRecord::Migration[8.0]
  def change
    remove_column :addresses, :poboxnumber
  end
end

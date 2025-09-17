class AddIndexToAddressesPostcodeColumn < ActiveRecord::Migration[8.0]
  def change
    add_index :addresses, :postcode
  end
end

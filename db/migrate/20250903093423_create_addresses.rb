class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :uprn
      t.string :organisation_name
      t.string :po_box_number
      t.string :sub_name
      t.string :name
      t.string :number
      t.string :street_name
      t.string :locality
      t.string :town_name
      t.string :postcode
      t.string :full_address
    end
  end
end

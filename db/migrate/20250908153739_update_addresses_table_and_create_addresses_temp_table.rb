class UpdateAddressesTableAndCreateAddressesTempTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :addresses
    create_table :addresses, id: false, primary_key: :uprn do |t|
      t.string :uprn
      t.string :parentuprn
      t.string :organisationname
      t.string :poboxnumber
      t.string :subname
      t.string :name
      t.string :number
      t.string :streetname
      t.string :locality
      t.string :townname
      t.string :postcode
      t.string :fulladdress
      t.string :country
      t.string :classificationcode
    end

    execute "ALTER TABLE addresses ADD PRIMARY KEY (uprn)"
  end
end

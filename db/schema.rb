# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_17_101624) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", primary_key: "uprn", id: :string, force: :cascade do |t|
    t.string "parentuprn"
    t.string "organisationname"
    t.string "poboxnumber"
    t.string "subname"
    t.string "name"
    t.string "number"
    t.string "streetname"
    t.string "locality"
    t.string "townname"
    t.string "postcode"
    t.string "fulladdress"
    t.string "country"
    t.string "classificationcode"
    t.index ["postcode"], name: "index_addresses_on_postcode"
  end

  create_table "addresses_temp", primary_key: "uprn", id: :string, force: :cascade do |t|
    t.string "parentuprn"
    t.string "organisationname"
    t.string "poboxnumber"
    t.string "subname"
    t.string "name"
    t.string "number"
    t.string "streetname"
    t.string "locality"
    t.string "townname"
    t.string "postcode"
    t.string "fulladdress"
    t.string "country"
    t.string "classificationcode"
  end
end

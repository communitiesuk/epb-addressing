module Gateway
  class AddressesGateway
    def search_by_building_number_and_postcode(building_numbers:, postcode:)
      insert_sql = <<-SQL
        SELECT fulladdress,
               postcode,
               uprn,
               parentuprn
        FROM addresses
        WHERE postcode = $2
        AND to_tsvector('simple', fulladdress) @@ to_tsquery('simple', REPLACE($1, ' ', ' & '));
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "building_numbers",
          building_numbers,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "postcode",
          postcode,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(insert_sql, "SQL", bindings).to_a
    end

    def search_by_postcode(postcode:)
      insert_sql = <<-SQL
        SELECT fulladdress,
               postcode,
               uprn,
               parentuprn
        FROM addresses
        WHERE postcode = $1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "postcode",
          postcode,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(insert_sql, "SQL", bindings).to_a
    end
  end
end

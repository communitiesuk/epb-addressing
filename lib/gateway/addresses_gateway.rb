module Gateway
  class AddressesGateway
    def search_by_building_number_and_postcode(building_numbers:, postcode:)
      insert_sql = <<-SQL
        SELECT fulladdress as address,
               postcode,
               uprn,
               parentuprn as parent_uprn
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
        SELECT fulladdress as address,
               postcode,
               uprn,
               parentuprn as parent_uprn
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

    def search_by_uprns(uprns:)
      insert_sql = <<-SQL
        SELECT fulladdress as address,
               postcode,
               uprn,
               parentuprn as parent_uprn
        FROM addresses
      SQL

      insert_sql << " JOIN ( VALUES "
      insert_sql << uprns.each_with_index.map { |_, idx| "($#{1 + idx})" }.join(", ")
      insert_sql << ") uprn (u) "
      insert_sql << "ON (uprn = u)"

      bindings = []
      uprns.each_with_index do |uprn, idx|
        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "uprn_#{idx + 1}",
          uprn,
          ActiveRecord::Type::String.new,
        )
      end

      ActiveRecord::Base.connection.exec_query(insert_sql, "SQL", bindings).to_a
    end
  end
end

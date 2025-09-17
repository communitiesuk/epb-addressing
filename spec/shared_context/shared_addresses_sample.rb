require "csv"

shared_context "when accessing addresses table" do
  def import_sample_data
    conn = ActiveRecord::Base.connection

    file_path = File.join Dir.pwd, "spec/fixtures/samples/add_gb_builtaddress.csv"

    table_columns = ActiveRecord::Base.connection.columns("addresses").map(&:name)

    CSV.foreach(file_path, headers: true) do |row|
      filtered = row.to_h.slice(*table_columns)

      next if filtered.empty?

      columns = filtered.keys
      values  = columns.map { |c| conn.quote(filtered[c]) }

      columns_sql = columns.join(", ")
      values_sql = values.join(", ")

      sql = <<~SQL
        INSERT INTO addresses (#{columns_sql})
        VALUES (#{values_sql})
      SQL
      conn.exec_query(sql)
    end
  end
end

describe "addresses table" do
  it "finds the table" do
    sql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'addresses';"
    result = ActiveRecord::Base.connection.exec_query(sql)
    expect(result.length).to eq(1)
  end

  it "finds the following columns for the addresses table" do
    sql = "SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name LIKE 'addresses';"
    result = ActiveRecord::Base.connection.exec_query(sql).rows.flatten.sort
    expect(result).to eq(%w[classificationcode country fulladdress locality name number organisationname parentuprn postcode source streetname subname townname uprn])
  end
end

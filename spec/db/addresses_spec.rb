describe "addresses table" do
  it "finds the table" do
    sql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'addresses';"
    result = ActiveRecord::Base.connection.exec_query(sql)
    expect(result.length).to eq(1)
  end
end

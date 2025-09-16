describe Helper::Address, type: :helper do
  context "when performing basic cleaning" do
    it "replaces punctuation with spaces" do
      expect(described_class.clean_address_string("123, Main. Street!")).to eq("123 MAIN STREET")
      expect(described_class.clean_address_string("123-A/B Street")).to eq("123A B STREET")
      expect(described_class.clean_address_string("102:104 High Street")).to eq("102 104 HIGH STREET")
    end

    it "replaces symbols with words" do
      expect(described_class.clean_address_string("Flat 42 & 3")).to eq("FLAT 42 and 3")
      expect(described_class.clean_address_string("123@Test Street")).to eq("123 at TEST STREET")
    end

    it "removes quotes" do
      expect(described_class.clean_address_string("Flat 42's")).to eq("FLAT 42S")
    end

    it "collapses multiple spaces" do
      expect(described_class.clean_address_string("123   Main    Street")).to eq("123 MAIN STREET")
      expect(described_class.clean_address_string(" 123 Main Street \n")).to eq("123 MAIN STREET")
    end

    it "replaces common abbreviations" do
      expect(described_class.clean_address_string("123 Main St")).to eq("123 MAIN STREET")
      expect(described_class.clean_address_string("123 Secondary Rd")).to eq("123 SECONDARY ROAD")
    end
  end

  context "when fixing building numbers" do
    it "removes the space between a number and a single letter" do
      expect(described_class.clean_address_string("17 C High Street")).to eq("17C HIGH STREET")
    end

    it "handles two-digit building numbers" do
      expect(described_class.clean_address_string("23 B Fake Road")).to eq("23B FAKE ROAD")
    end

    it "handles multi-digit building numbers" do
      expect(described_class.clean_address_string("2456 A Long Lane")).to eq("2456A LONG LANE")
    end
  end

  context "when removing postal counties" do
    it "removes a long-form county at the end of the string" do
      expect(described_class.clean_address_string("123 Test Street, Greater Manchester")).to eq("123 TEST STREET")
    end

    it "removes a short-form county at the end of the string" do
      expect(described_class.clean_address_string("123 Fake Lane, A12 B13, Cambs")).to eq("123 FAKE LANE A12 B13")
    end

    it "does not remove a county if it is part of a street name" do
      expect(described_class.clean_address_string("123 Hampshire Street")).to eq("123 HAMPSHIRE STREET")
    end
  end

  context "when handling combined rules" do
    it "applies all rules to a complex string" do
      input = "17 B (C) high, street, greater manchester"
      expected = "17B C HIGH STREET"
      expect(described_class.clean_address_string(input)).to eq(expected)
    end

    it "handles a real-world example with multiple issues" do
      input = "Unit 5 - The Grange, Essex"
      expected = "UNIT 5 THE GRANGE"
      expect(described_class.clean_address_string(input)).to eq(expected)
    end
  end
end

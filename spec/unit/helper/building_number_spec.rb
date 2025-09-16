describe Helper::BuildingNumber, type: :helper do
  context "when extracting building numbers from address" do
    it "extracts single-digit building number" do
      expect(described_class.extract_building_numbers("4, LANDSCORE ROAD, EXETER, EX4 1EW")).to eq("4")
    end

    it "extracts a two-digit building number" do
      expect(described_class.extract_building_numbers("47, EDWARDS COURT, MILLBROOK LANE, EXETER, EX2 6FU")).to eq("47")
    end

    it "extracts a three-digit building number" do
      expect(described_class.extract_building_numbers("132, SWEETBRIER LANE, EXETER, EX1 3AR")).to eq("132")
    end

    it "extracts a four-digit building number" do
      expect(described_class.extract_building_numbers("1234, HIGH STREET, LONDON, SW1A 0AA")).to eq("1234")
    end

    it "extracts a four-digit plus letter building number" do
      expect(described_class.extract_building_numbers("1234B, HIGH STREET, LONDON, SW1A 0AA")).to eq("1234B")
    end

    it "does not extract building numbers with more than four digits" do
      expect(described_class.extract_building_numbers("12345, HIGH STREET, LONDON, SW1A 0AA")).to eq("")
    end

    it "handles addresses without a building number" do
      expect(described_class.extract_building_numbers("NEW COTTAGE, TADDYFORDE ESTATE, EXETER, EX4 4AT")).to eq("")
    end

    it "extracts the building number from a multi-line address" do
      expect(described_class.extract_building_numbers("THIRD FLOOR FLAT 14, THE DEPOT, BAMPFYLDE STREET, EXETER, EX1 2FW")).to eq("14")
    end

    it "extracts a building number with an appended letter" do
      expect(described_class.extract_building_numbers("63A, RIFFORD ROAD, EXETER, EX2 5LA")).to eq("63A")
    end

    it "extracts a building number with an appended letter after a space" do
      expect(described_class.extract_building_numbers("62 A, RIFFORD ROAD, EXETER, EX2 5LA")).to eq("62A")
    end

    it "extracts multiple building numbers from a complex address" do
      expect(described_class.extract_building_numbers("ROOM 5 FIRST FLOOR FLAT 1, BLOCK A EAST PARK, RENNES DRIVE, EXETER, EX4 4GX")).to eq("5 1")
    end
  end
end

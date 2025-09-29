module Helper
  class PotentialMatches
    def self.merge_parents(potential_matches:, parents:)
      # Combine parents on potential_matches when they include a new full address
      potential_matches_addresses = potential_matches.map { |potential_match| potential_match["full_address"] }
      filtered_parents = parents.map { |parent| potential_matches_addresses.include?(parent["full_address"]) ? nil : parent.merge({ "is_parent" => 1 }) }.compact
      potential_matches.concat(filtered_parents)
    end

    # this is setting clean address 2
    def self.add_clean_address(potential_matches:)
      potential_matches.each do |potential_match|
        potential_match["clean_address"] = Helper::Address.clean_address_string(potential_match["full_address"])
      end
    end

    # TokensOut
    def self.add_tokens_out(potential_matches:)
      potential_matches.each do |potential_match|
        potential_match["tokens_out"] = Helper::Address.calculate_tokens(potential_match["clean_address"])
      end
    end

    # Refers to LenBuildingNum2 in the algorithm
    def self.add_building_tokens(potential_matches:)
      potential_matches.each do |potential_match|
        building_numbers = Helper::BuildingNumber.extract_building_numbers(potential_match["clean_address"])
        potential_match["building_tokens"] = Helper::Address.calculate_tokens(building_numbers)
      end
    end

    # LenBuildingNumIntersect
    def self.add_count_building_num_intersect(extracted_building_number:, potential_matches:)
      potential_matches.each do |potential_match|
        potential_match["count_building_num_intersect"] = Helper::Matching.count_tokens_intersect(input: extracted_building_number, potential_match: Helper::BuildingNumber.extract_building_numbers(potential_match["clean_address"]))
      end
    end

    # TokensIntersect
    def self.add_tokens_intersect(input:, potential_matches:)
      potential_matches.each do |potential_match|
        potential_match["count_tokens_intersect"] = Helper::Matching.count_tokens_intersect(input:, potential_match: potential_match["clean_address"])
      end
    end

    def self.remove_matches(potential_matches:, attribute_name:)
      max_tokens_match = potential_matches.max_by { |hash| hash[:score] }[attribute_name]
      potential_matches.reject! { |potential_match| potential_match[attribute_name] < max_tokens_match }
      potential_matches
    end

    def self.count_exact_numbers_and_not_parents(extracted_building_number:, potential_matches:)
      potential_matches.count { |potential_match| (Helper::BuildingNumber.extract_building_numbers(potential_match["clean_address"]) == extracted_building_number) && potential_match["is_parent"] != 1 }
    end

    def self.remove_parents(potential_matches:)
      potential_matches.reject! { |potential_match| (potential_match["is_parent"] == 1) }
      potential_matches
    end

    def self.remove_non_exact_numbers(extracted_building_number:, potential_matches:)
      potential_matches.select! { |potential_match| (Helper::BuildingNumber.extract_building_numbers(potential_match["clean_address"]) == extracted_building_number) }
      potential_matches.each do |potential_match|
        potential_match["building_number_exact"] = 1
      end
    end

    def self.add_tokens_matches_1(input:, potential_matches:)
      potential_matches.each do |potential_match|
        potential_match["count_tokens_matches_1"] = Helper::Matching.count_tokens_matching(string_1: input, string_2: potential_match["clean_address"])
      end
    end

    def self.add_tokens_matches_2(input:, potential_matches:)
      potential_matches.each do |potential_match|
        potential_match["count_tokens_matches_2"] = Helper::Matching.count_tokens_matching(string_1: potential_match["clean_address"], string_2: input)
      end
    end

    def self.add_percentage_match(potential_matches:)
      potential_matches.each do |potential_match|
        potential_match["percentage_match"] = potential_match["count_tokens_matches_2"].to_f / potential_match["tokens_out"]
      end
    end
  end
end

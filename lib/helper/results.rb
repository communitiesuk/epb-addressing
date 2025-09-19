module Helper
  class Results
    def self.merge_parents(results:, parents:)
      # Combine parents on results when they include a new full address
      results_addresses = results.map { |result| result["full_address"] }
      filtered_parents = parents.map { |parent| results_addresses.include?(parent["full_address"]) ? nil : parent.merge({ "is_parent" => 1 }) }.compact
      results.concat(filtered_parents)
    end

    # this is setting clean address 2
    def self.add_clean_address(results:)
      results.each do |result|
        result["clean_address"] = Helper::Address.clean_address_string(result["full_address"])
      end
    end

    def self.add_tokens_out(results:)
      results.each do |result|
        result["tokens_out"] = Helper::Address.calculate_tokens(result["clean_address"])
      end
    end
  end
end

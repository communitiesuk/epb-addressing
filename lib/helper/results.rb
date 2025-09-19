module Helper
  class Results
    def self.merge_parents(results:, parents:)
      # Combine parents on results when they include a new fulladdress
      results_addresses = results.map { |result| result["fulladdress"] }
      filtered_parents = parents.map { |parent| results_addresses.include?(parent["fulladdress"]) ? nil : parent }.compact
      results.concat(filtered_parents)
    end

    # this is setting clean address 2
    def self.add_clean_address(results:)
      results.each do |result|
        result["cleanaddress"] = Helper::Address.clean_address_string(result["fulladdress"])
      end
    end
  end
end

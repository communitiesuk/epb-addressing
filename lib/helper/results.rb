module Helper
  class Results
    def self.merge_parents(results:, parents:)
      # Combine parents on results when they include a new fulladdress
      results_addresses = results.map { |result| result["fulladdress"] }
      filtered_parents = parents.map { |parent| results_addresses.include?(parent["fulladdress"]) ? nil : parent }.compact
      results.concat(filtered_parents)
    end
  end
end

module Helper
  class Matching
    def self.count_tokens_intersect(input:, result:)
      input_array = input.split
      result_array = result.split
      tokens_intersect = 0
      # loop over each token in string 1
      input_array.each do |token|
        next unless result_array.include?(token)

        # increase the count if it is in the second string
        tokens_intersect += 1
        # remove the token from string 2 if present
        result_array.slice!(result_array.index(token))
      end
      tokens_intersect
    end
  end
end

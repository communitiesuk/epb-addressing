module Helper
  class Matching
    def self.count_tokens_intersect(input:, potential_match:)
      input_array = input.split
      potential_match_array = potential_match.split
      tokens_intersect = 0
      # loop over each token in string 1
      input_array.each do |token|
        next unless potential_match_array.include?(token)

        # increase the count if it is in the second string
        tokens_intersect += 1
        # remove the token from string 2 if present
        potential_match_array.slice!(potential_match_array.index(token))
      end
      tokens_intersect
    end
  end
end

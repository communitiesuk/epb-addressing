module Helper
  class BuildingNumber
    def self.extract_building_numbers(full_address)
      # Prepare the input address, this may come "clean" in the future.
      clean_address = Helper::Address.clean_address_string(full_address)

      # The regex pattern `\b(\d+[A-Z]?)\b` is used to find all building numbers.
      # - `\b`: A word boundary. This ensures that we match whole numbers, not parts of a larger number.
      # - `\d{1,4}`: Matches one or up to 4 digits (0-9).
      # - `[A-Z]?`: Matches an optional single uppercase letter.
      # - `()`: Capturing group. We want to extract the matched number itself.

      # The `scan` method returns an array of all non-overlapping matches.
      # The `strip` method is called on each match to remove any leading/trailing spaces.
      building_numbers = clean_address.scan(/\b(\d{1,4}[A-Z]?)\b/).flatten.map(&:strip)

      # Join the found building numbers with a space and return the resulting string.
      building_numbers.join(" ")
    end
  end
end

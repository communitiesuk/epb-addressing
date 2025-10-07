module Helper
  class Postcode
    POSTCODE_REGEX = "^[a-zA-Z][a-zA-Z0-9]{1,3}\s[0-9][A-Za-z]{2}$".freeze

    def self.validate(postcode)
      # Clean leading and trailing whitespaces
      postcode&.strip!

      # Uppercase
      postcode&.upcase!

      # Remove all whitespaces
      postcode.gsub!(/[[:space:]]/, "")

      # adds a space before last 3 characters
      postcode.insert(-4, " ") unless postcode.length < 3

      unless Regexp.new(POSTCODE_REGEX, Regexp::IGNORECASE).match?(postcode)
        raise Errors::PostcodeNotValid
      end

      postcode
    end
  end
end

module Helper
  class Address
    # frozen_string_literal: true

    def self.clean_address_string(address_string)
      # Ensure the input is a string
      return "" unless address_string.is_a?(String)

      # Convert to a mutable string
      string = address_string.dup

      # Uppercase the full address
      string.upcase!
      # Replace specific punctuation with spaces
      string.gsub!(/[,.\-_\\\/();:]/, " ")
      # Remove specific punctuation
      string.gsub!(/['?`*!#]/, "")

      # Replace "amp;", "&", and "+" with " and "
      string.gsub!(/amp;|&|\+/, " AND ")

      # Replace "@" with " at "
      string.gsub!("@", " AT ")

      # Collapse multiple spaces into a single space
      string.squeeze!(" ")

      # Fix building numbers like "17 C" to "17C"
      string.gsub!(/\b(\d{1,4})\s([A-Z])\b/) do
        "#{::Regexp.last_match(1)}#{::Regexp.last_match(2)}"
      end

      # Strip leading and trailing whitespace
      string.strip!

      # Remove specific postal counties if they appear after the 16th character
      # We use an array for an efficient lookup
      postal_counties = [
        "GREATER MANCHESTER",
        "NORTH HUMBERSIDE",
        "NORTHAMPTONSHIRE",
        "SOUTH HUMBERSIDE",
        "BUCKINGHAMSHIRE",
        "GLOUCESTERSHIRE",
        "NORTH YORKSHIRE",
        "NOTTINGHAMSHIRE",
        "SOUTH YORKSHIRE",
        "CAMBRIDGESHIRE",
        "GREATER LONDON",
        "LEICESTERSHIRE",
        "NORTHUMBERLAND",
        "WEST YORKSHIRE",
        "WORCESTERSHIRE",
        "COUNTY DURHAM",
        "HEREFORDSHIRE",
        "HERTFORDSHIRE",
        "ISLE OF WIGHT",
        "STAFFORDSHIRE",
        "TYNE AND WEAR",
        "WEST MIDLANDS",
        "BEDFORDSHIRE",
        "LINCOLNSHIRE",
        "N HUMBERSIDE",
        "S HUMBERSIDE",
        "WARWICKSHIRE",
        "EAST SUSSEX",
        "N YORKSHIRE",
        "OXFORDSHIRE",
        "S YORKSHIRE",
        "TYNE & WEAR",
        "W YORKSHIRE",
        "WEST SUSSEX",
        "DERBYSHIRE",
        "LANCASHIRE",
        "MERSEYSIDE",
        "SHROPSHIRE",
        "W MIDLANDS",
        "BERKSHIRE",
        "CLEVELAND",
        "CO DURHAM",
        "HAMPSHIRE",
        "MIDDLESEX",
        "NORTHANTS",
        "WILTSHIRE",
        "CHESHIRE",
        "CORNWALL",
        "E SUSSEX",
        "SOMERSET",
        "W SUSSEX",
        "CUMBRIA",
        "NORFOLK",
        "SUFFOLK",
        "DORSET",
        "NORTHD",
        "STAFFS",
        "SURREY",
        "BERKS",
        "BUCKS",
        "CAMBS",
        "DEVON",
        "ESSEX",
        "HANTS",
        "HERTS",
        "LANCS",
        "LEICS",
        "LINCS",
        "MIDDX",
        "NOTTS",
        "POWYS",
        "WARKS",
        "WILTS",
        "WORCS",
        "AVON",
        "BEDS",
        "GLOS",
        "KENT",
        "OXON",
      ]

      # For efficient replacement, use a regex created from the keys
      postal_counties_regex = Regexp.union(postal_counties.map { |county| /\b#{Regexp.escape(county)}\b/ })

      # Replace the counties if they appear after the 16th character
      if string.length > 16
        string[16..] = string[16..].gsub(postal_counties_regex, "")
      end

      # Replace common abbreviations
      string.gsub!(/\bST\b/i, "STREET")
      string.gsub!(/\bRD\b/i, "ROAD")

      # Return the cleaned string
      string.strip
    end

    def self.calculate_tokens(clean_string)
      clean_string.count(" ") + 1
    end
  end
end

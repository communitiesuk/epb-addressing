require 'csv'
require 'optparse' # Add the library for command-line argument parsing
require 'ostruct' # Used by optparse to store options

# 1. Configuration Setup
options = OpenStruct.new(pause_enabled: false)

# 2. Command Line Argument Parsing
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script_name.rb [options] <path/to/your/file.csv>"

  # -p flag for Pause/Paging
  opts.on("-p", "--pause", "Enable interactive paging (pauses every 5 addresses matched to check).") do
    options.pause_enabled = true
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse! # parse! removes options from ARGV, leaving only the file path

# Check if a file path was provided as an argument
if ARGV.empty?
  puts "Error: Missing CSV file path."
  puts "Use -h for help."
  exit 1
end

# Get the CSV file path from the command-line arguments
csv_file_path = ARGV[0]

# Initialize all counters
count = 0
uprn_match_count = 0          # address_id starts with UPRN- AND ends with uprn value
valid_uprn_missing_count = 0  # address_id starts with UPRN- AND doesn't end with uprn value AND uprn is not 'none'
addresses_not_found_count = 0 # uprn column is 'none'
addresses_matched_to_check = 0 # address_id doesn not start with UPRN- and there's a match

begin
  # Open and read the CSV file
  # The 'headers: true' option treats the first row as headers and allows access by column name
  CSV.foreach(csv_file_path, headers: true, skip_blanks: true) do |row|
    count += 1

    # Safely access the necessary columns. Using || '' ensures a String for comparison/output.
    address_id = (row['address_id'] || '').strip
    uprn = (row['uprn'] || '').strip.downcase # Downcase 'uprn' to handle 'None' vs 'none'

    # --- Check 1: UPRN is explicitly marked as missing ('none') ---
    if uprn == 'none'
      addresses_not_found_count += 1
      next # Skip all further checks for this row

    # --- Check 2: address_id starts with 'UPRN-' (The primary comparison group) ---
    elsif address_id.start_with?('UPRN-')

      # Check 2a: Perfect match
      if address_id.end_with?(uprn)
        uprn_match_count += 1

      # Check 2b: Mismatch with a valid UPRN
      else
        # The uprn value is present and not 'none', but it doesn't match the address_id suffix
        valid_uprn_missing_count += 1
      end

    # --- Check 3: Output Address for comparison (address_id doesn't start with UPRN-) ---
    else
      # Safely collect all address components for output
      address_parts = [
        row['address_line1'],
        row['address_line2'],
        row['address_line3'],
        row['address_line4'],
        row['town'],
        row['postcode']
      ].compact.reject(&:empty?).join(', ')

      # Get the pre-existing address string from the 'address' column
      address_column_value = row['address']

      puts "=================================================="
      puts "Address ID Format Mismatch (ID: #{address_id}) - Check Address Text:"
      puts "Constructed Address (from individual lines):"
      puts "\t#{address_parts}"
      puts "Address Column Value (for comparison):"
      puts "\t#{address_column_value}"
      puts "=================================================="

      addresses_matched_to_check += 1
      if options.pause_enabled && (addresses_matched_to_check % 5 == 0)
        puts "\n--- Press ENTER to continue to the next 5 address checks (Currently at: #{addresses_matched_to_check}) ---"
        STDIN.gets # STDIN.gets waits for user input (Enter key)
      end
    end
  end

  # Output the final count of all checks
  puts "\n--- Final Summary of Data Checks ---"
  puts "✅ **Existing UPRN Matched (address_id ends with uprn)**:       #{uprn_match_count}"
  puts "⚠️  **Existing UPRN missing (address_id != uprn suffix)**:       #{valid_uprn_missing_count}"
  puts "❌ **Addresses Not Found (uprn column is 'none')**:             #{addresses_not_found_count}"
  puts "----------------------------------------------------"
  puts "🔎 **Addresses without UPRN (address_id format is non-UPRN)**:  #{addresses_matched_to_check}"
  puts "----------------------------------------------------" 
  puts "Total rows processed: #{count}" # $..count is a useful shortcut for the row count inside CSV.foreach

rescue Errno::ENOENT
  puts "Error: File not found at path '#{csv_file_path}'"
rescue CSV::MalformedCSVError => e
  puts "Error processing CSV file: #{e.message}"
rescue StandardError => e
  puts "An unexpected error occurred: #{e.message}"
end

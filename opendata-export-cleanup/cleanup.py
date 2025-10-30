#!/usr/bin/env python3
import sys
import os
import pandas as pd

def main():
    if len(sys.argv) < 2:
        print("Usage: python transform_csv.py <input_csv_path>")
        sys.exit(1)

    input_path = sys.argv[1]
    if not os.path.exists(input_path):
        print(f"Error: File not found: {input_path}")
        sys.exit(1)

    # Output file will be in the directory where the script is run
    output_path = os.path.join(os.getcwd(), "trimmed.csv")

    print(f"Reading input CSV: {input_path}")
    df = pd.read_csv(input_path)

    print(f"Loaded {len(df)} rows")
    # Filter rows where UPRN_SOURCE == "Address Matched"
    if "UPRN_SOURCE" in df.columns:
        df = df[df["UPRN_SOURCE"] == "Address Matched"]
        print(f"Filtered to {len(df)} rows with UPRN_SOURCE = 'Address Matched'")
    else:
        print("Warning: UPRN_SOURCE column not found — keeping all rows")

    # Build the new DataFrame with selected & renamed columns
    new_df = pd.DataFrame({
        "postcode": df.get("POSTCODE", ""),
        "address_line1": df.get("ADDRESS1", ""),
        "address_line2": df.get("ADDRESS2", ""),
        "address_line3": df.get("ADDRESS3", ""),
        "address_line4": "",  # or df.get("LOCAL_AUTHORITY_LABEL", "")
        "town": df.get("POSTTOWN", ""),
        "address_id": df.get("UPRN", ""),
        "uprn_source": df.get("UPRN_SOURCE", ""),
        "type_of_assessment": df.get("REPORT_TYPE", "")
    })

    new_df.to_csv(output_path, index=False)
    print(f"✅ Done! Saved output to: {output_path}")

if __name__ == "__main__":
    main()


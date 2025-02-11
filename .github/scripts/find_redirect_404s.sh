#!/bin/bash
# Takes a list of docs.substrate.io URLs from the netlify _redirects file,
# and checks which of them return 404 response code after following redirects.

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "::error::Error: curl is required but not installed"
    exit 1
fi

# Check if input file is provided
if [ "$#" -ne 1 ]; then
    echo "::error::Usage: $0 <url_list_file>"
    echo "::error::url_list_file: Invalid number of arguments"
    exit 1
fi

input_file="$1"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "::error::Error: File '$input_file' not found"
    exit 1
fi

# Process each URL
echo "::warning::The following polkadot.com URLs are missing:"
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Extract path and destination
    path=$(echo "$line" | awk '{print $1}' | xargs)
    destination=$(echo "$line" | awk '{print $2}' | xargs)
    source_url="https://docs.substrate.io${path}"

    # Get HTTP response code with timeout, following redirects
    response=$(curl -L -o /dev/null -s -w "%{http_code}" -m 10 "$destination")

    if [ "$response" = "404" ]; then
        echo "::warning::$destination"
    fi
done < "$input_file"

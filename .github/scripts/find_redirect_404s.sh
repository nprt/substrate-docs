#!/bin/bash
# Takes a list of URLs from a file, and using `curl` checks which of them
# return 404 response code.
# It is used to keep an eye on docs.substrate.io redirects towards
# docs.polkadot.com.

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed"
    exit 1
fi

# Check if input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url_list_file>"
    echo "url_list_file: Text file containing one URL per line"
    exit 1
fi

input_file="$1"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found"
    exit 1
fi

# Process each URL
echo "The following polkadot.com URLs are missing:"
while IFS= read -r url || [ -n "$url" ]; do
    # Skip empty lines
    [ -z "$url" ] && continue

    # Trim whitespace
    url=$(echo "$url" | xargs)

    # Get HTTP response code with timeout
    response=$(curl -o /dev/null -s -w "%{http_code}" -m 10 "$url")

    if [ "$response" = "404" ]; then
        echo "$url"
    fi
done < "$input_file"

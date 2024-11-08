#!/bin/bash

# Función para manejar errores
handle_error() {
    local error_message=$1
    echo "<data><error>${error_message}</error></data>" > congress_data.xml
    echo "Error: $error_message"
    exit 1
}

# Función para realizar la solicitud y verificar el resultado
fetch_data() {
    local url=$1
    local output_file=$2

    curl -X GET "$url" -H "accept: application/xml" -o "$output_file"
    
    if [ $? -ne 0 ]; then
        handle_error "Error: Failed to fetch data from the API."
    else
        echo "XML file generated successfully: $output_file"
    fi
}


if [ $# -ne 1 ]; then
    handle_error "Congress number must not be empty."
fi
congress_number=$1

# Verifica que el numero de congreso este entre 1 y 118
if ! [[ "$congress_number" =~ ^[0-9]+$ ]] || [ "$congress_number" -lt 1 ] || [ "$congress_number" -gt 118 ]; then
    handle_error "Congress number must be an integer between 1 and 118."
fi

# Verifica que CONGRESS_API esté definida
if [ -z "$CONGRESS_API" ]; then
    handle_error "The CONGRESS_API environment variable is not set."
fi

xml_congress_info_output="congress_info.xml"
xml_congress_members_info_output="congress_members_info.xml"

fetch_data "https://api.congress.gov/v3/congress/$congress_number?format=xml&api_key=${CONGRESS_API}" "$xml_congress_info_output"
fetch_data "https://api.congress.gov/v3/member/congress/$congress_number?format=xml&currentMember=false&limit=500&api_key=${CONGRESS_API}" "$xml_congress_members_info_output"

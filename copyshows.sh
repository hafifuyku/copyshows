#!/bin/bash

# -----------------------------
# CONFIG
# -----------------------------

source_directory=""
destination_directory=""

PLEX=""
TOKEN="YOUR_TOKEN"
TV_SECTION=6

changes_made=0

# -----------------------------
# PROCESS FILES
# -----------------------------

for item in "$source_directory"/*; do
    if [ -f "$item" ] || [ -d "$item" ]; then

        filename=$(basename "$item")

        tv_show_name=$(echo "$filename" | sed -E 's/(.*[.])?[Ss]([0-9]+)[Ee]([0-9]+).*/\1/' | tr '.' ' ')
        season_number=$(echo "$filename" | sed -E 's/.*[Ss]([0-9]+)[Ee][0-9]+.*/\1/')
        episode_number=$(echo "$filename" | sed -E 's/.*[Ss][0-9]+[Ee]([0-9]+).*/\1/')

        tv_show_name=${tv_show_name%" "}
        tv_show_name=$(echo "$tv_show_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

        # Skip if parsing failed
        if [ -z "$season_number" ] || [ -z "$episode_number" ]; then
            continue
        fi

        # Find existing show folder (case-insensitive)
        show_folder=""
        for folder in "$destination_directory"/*; do
            if [ -d "$folder" ]; then
                folder_name=$(basename "$folder")
                if [[ "$(echo "$tv_show_name" | tr '[:upper:]' '[:lower:]')" == "$(echo "$folder_name" | tr '[:upper:]' '[:lower:]')" ]]; then
                    show_folder="$folder"
                    break
                fi
            fi
        done

        # Create show folder if needed
        if [ -z "$show_folder" ]; then
            show_folder="$destination_directory/$tv_show_name"
            mkdir -p "$show_folder"
        fi

        # Create season folder if needed
        season_folder="$show_folder/Season $season_number"
        mkdir -p "$season_folder"

        # Move file
        mv "$item" "$season_folder"
        changes_made=1
    fi
done

# -----------------------------
# PLEX REFRESH
# -----------------------------

if [ "$changes_made" -eq 1 ]; then
    echo "Stopping any ongoing Plex scan..."
    curl -s "$PLEX/library/sections/$TV_SECTION/refresh?force=1&X-Plex-Token=$TOKEN" > /dev/null

    echo "Triggering targeted Plex scan..."
    curl -s "$PLEX/library/sections/$TV_SECTION/refresh?path=$destination_directory&X-Plex-Token=$TOKEN" > /dev/null

    echo "Plex scan triggered."
else
    echo "No new files moved. Plex not triggered."
fi

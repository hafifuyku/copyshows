#!/bin/bash

# Specify the source directory where the downloaded files/folders are located
source_directory="/home/hasan/goodsamaritan/chill.institute"

# Specify the destination directory where the TV show folders are located
destination_directory="/home/hasan/goodsamaritan/Motherlode/tv"

# Loop through each file or folder in the source directory
for item in "$source_directory"/*; do
    if [ -f "$item" ] || [ -d "$item" ]; then
        echo "Processing:"

        # Extract the TV show name, season number, and episode number from the file or folder name
        filename=$(basename "$item")
        tv_show_name=$(echo "$filename" | sed -E 's/(.*[.])?[Ss]([0-9]+)[Ee]([0-9]+).*/\1/' | tr '.' ' ')
        season_number=$(echo "$filename" | sed -E 's/.*[Ss]([0-9]+)[Ee][0-9]+.*/\1/')
        episode_number=$(echo "$filename" | sed -E 's/.*[Ss][0-9]+[Ee]([0-9]+).*/\1/')

        tv_show_name=${tv_show_name%" "}  # Remove trailing space from show name
        tv_show_name=$(echo "$tv_show_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1') # Convert show name to title case

        echo "TV Show Name: $tv_show_name"
        echo "Season Number: $season_number"
        echo "Episode Number: $episode_number"

        # Check if the TV show folder exists in the destination directory (ignoring case sensitivity)
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

        echo "TV Show Folder: $show_folder"

        # If the TV show folder doesn't exist, create it
        if [ -z "$show_folder" ]; then
            show_folder="$destination_directory/$tv_show_name"
            mkdir "$show_folder"
            echo "Created show folder: $show_folder"
        fi

        # Find or create the season folder within the TV show folder
        season_folder="$show_folder/Season $season_number"
        if [ ! -d "$season_folder" ]; then
            mkdir "$season_folder"
            echo "Created season folder: $season_folder"
        fi

        # Move the file or folder to the season folder
        mv "$item" "$season_folder"
        echo "Moved episode $episode_number to $season_folder"
    fi
done

#!/bin/bash

################################################################################
# File: watch-image-in-folder.sh
# Description: A bash script to monitor changes in a specified folder and its
#              subfolders. It triggers the execution of a custom script named
#              resize.sh for image files (jpg or png) created or edited,
#              excluding existing thumbnails located in paths containing "/tn/".
# Author: Pumbaa
# Date: 08.03.2024
################################################################################


# Check if inotifywait is installed
if ! [ -x "$(command -v inotifywait)" ]; then
  echo 'Error: inotifywait is not installed. Install it using "sudo apt-get install inotify-tools".' >&2
  exit 1
fi

# Check if resize.sh script exists in the current directory
if [ ! -f "resize.sh" ]; then
  echo "Error: resize.sh script not found in the current directory."
  exit 1
fi

# Check if the correct number of arguments is provided
if [ "$#" -el 1 ]; then
  echo "Usage: $0 <folder_to_watch> <image_reference_path:optional>"
  exit 1
fi

# Check if the provided directory exists
if ! [ -d "$1" ]; then
  echo "Error: Folder '$1' does not exist."
  exit 1
fi

# Start monitoring the specified folder and its subfolders for create, modify, and delete events
inotifywait -m -r -e create -e modify -e delete "$1" --format '%w%f' |
while read -r file; do
  # Check if the file is a jpg or png image
  if [[ "$file" =~ \.jpg$ ]] || [[ "$file" =~ \.jpeg$ ]] || [[ "$file" =~ \.png$ ]]; then
  
    # Don't resize thumbnails
    if [[ "$file" != *"/tn/"* ]]; then

        # Run the resize.sh script for folder containing images
        filePath=$(dirname "$file")
        ./resize.sh "$filePath" $2 &
    fi
  fi
done

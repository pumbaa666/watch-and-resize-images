#!/bin/bash

################################################################################
# File: resize.sh
# Description: This bash script is responsible for resizing image files (jpg
#              or png) passed as arguments. It uses ImageMagick to perform the
#              resizing operation.
#
#              When it's done resizing it will output the HTML code to embed
#              the images in a post.
# Author: Pumbaa
# Date: 01.09.2023
################################################################################


DEBUG=true

rootFolder="$1"
tnFolder="$rootFolder/tn"

# keeps track of all the processed images
newPictures=""
existingPictures=""


# https://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
# https://search.brave.com/search?q=bash+how+to+check+if+a+file+with+space+exist&source=desktop
# TODO check if it works
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")


# loop through all pictures in the folder
for pictureFileName in $(ls "$rootFolder"); do
    # Check if the file exists
    if [ ! -f "$rootFolder/$pictureFileName" ]; then
        if $DEBUG; then
            echo "Skipping $pictureFileName because it does not exist"
        fi
        continue
    fi
    
    # Check if the file is a png or jpg
    if [[ ! "$pictureFileName" =~ \.(png|jpg)$ ]]; then
        if $DEBUG; then
            echo "Skipping $pictureFileName because it is not a png or jpg"
        fi
        continue
    fi
    
    # Check if the picture was already resized in the "tn" folder
    if [ -f "$tnFolder/$pictureFileName" ]; then
        if $DEBUG; then
            echo "Skipping $pictureFileName because it already exists in the 'tn' folder"
        fi
        existingPictures=$existingPictures"<a href=\"./img/$rootFolder/$pictureFileName\"><img src=\"./img/$tnFolder/$pictureFileName\" /></a>\n"
        continue
    fi
    
    # Create the "tn" folder if it doesn't exist
    if $DEBUG; then
        echo "Creating $tnFolder"
    fi
    mkdir -p $tnFolder
    
    # Resize the picture
    if $DEBUG; then
        echo "Resizing $pictureFileName"
    fi
    convert $rootFolder/$pictureFileName -resize 800x600 $tnFolder/$pictureFileName
    
    # Check if the picture was resized successfully
    if [ ! -f "$tnFolder/$pictureFileName" ]; then
        echo "Failed to resize $pictureFileName"
        continue
    fi
    
    # Print the original and resized picture path embeded in HTML tags
    newPictures=$newPictures"<a href=\"./img/$rootFolder/$pictureFileName\"><img src=\"./img/$tnFolder/$pictureFileName\" /></a>\n"
done


# Print result
if [ -n "$newPictures" ]; then
    echo -e "\n\nNew pictures:\n$newPictures"
fi

if [ -n "$existingPictures" ]; then
    echo -e "\n\nExisting pictures:\n$existingPictures"
fi

echo -e "\nDone !"


# restore $IFS
IFS=$SAVEIFS

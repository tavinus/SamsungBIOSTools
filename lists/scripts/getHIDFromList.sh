#!/bin/bash

###################################################################
#
# Bios List Hardware ID Parser by Tavinus
#
# To join multiple files
# cat file1 file2 file2 > output.txt
#
# Then sort and remove duplicates
# sort -u -o output.txt output.txt
#
###################################################################

HIDPVER=0.0.1
inputFile=''
f=''

rtError() {
        [[ -z "$1" ]] || echo "$1"
        exit 52
}

cleanTargets() {
        rm "$outputFile" 2>/dev/null
        rm "$outputFileSorted" 2>/dev/null
        touch "$outputFile" || rtError "Could not create output file: $outputFile"
}

processFile() {
        if [[ -z "$inputFile" ]] || [[ ! -f "$inputFile" ]]; then
                echo "Error: File not found: $inputFile"
                echo "Usage: $0 <fileToProcess.ext>"
                exit 11
        fi

        echo "Processing $inputFile, this could take a while..."
        
        
        # Read and process file
        while IFS="" read -r p || [ -n "$p" ]; do
                # For each line
                for i in $(printf '%s\n' "$p"); do
                        # Get value from XML Tag <FileName> if present
                        if [[ "${i,,}" == "<filename>"* ]]; then
                                f="$(echo $i | cut -d'>' -f 2 | cut -d'<' -f 1)"
                                # Remove folder and get the last part
                        else
                                f="$i"
                        fi
                        
                        # Get only basename
                        if [[ "${f,,}" == *'/'* ]]; then
                                f="$(echo $f | grep -o '[^/]*$')"
                        fi
                        
                        # Trim whitespaces
                        f="$(echo -e "$f" | tr -d '[:space:]')"
                        #echo "$f" ; echo "${f,,}"

                        # Show only if it starts with "item" and ends with "exe"
                        if [[ "${f,,}" == "item"* ]] && [[ "${f,,}" == *"exe" ]]; then
                                echo -n "$f > "
                                f="${f%%.exe*}"  # remove .exe from the end
                                f="${f%%.EXE*}"  # remove .exe from the end
                                f="${f##*_}"     # get all after last _
                                if [[ "${f:0:1}" == "P" ]]; then
                                        f="${f: -3:3}"
                                        echo "$f"
                                        echo "$f" >> "$outputFile"
                                else
                                        echo "Not a BIOS file, ignored"
                                fi
                        fi
                done
        done < "$inputFile"

        echo "Success!"
        echo "File created: $outputFile"
        echo "Creating sorted file..."
        sort -u -o "$outputFileSorted" "$outputFile" && echo "File created: $outputFileSorted"
}

echo "Tavinus Hardware ID Parser v$HIDPVER"

inputFile="$1"
outputFile="$inputFile"".hid.txt"
outputFileSorted="$inputFile"".hid.sorted.txt"

cleanTargets
processFile

echo "All done."
exit 0



#!/bin/bash

###################################################################
#
# Bios List Parser by Tavinus
#
# To join multiple files
# cat file1 file2 file2 > output.txt
#
# Then sort and remove duplicates
# sort -u -o output.txt output.txt
#
###################################################################

PBLVER=0.0.5

#inputFile1='BIOSItemList (Google Cache Jan 31 2013).txt'
#inputFile2='BIOSItemList(112912).xml'


inputFile=''
f=''

rtError() {
        [[ -z "$1" ]] || echo "$1"
        exit 52
}

cleanTargets() {
        rm "$outputFile" 2>/dev/null
        rm "$outputFileSorted" 2>/dev/null
}

processFile() {
        if [[ -z "$inputFile" ]] || [[ ! -f "$inputFile" ]]; then
                echo "Error: File not found: $inputFile"
                echo "Usage: $0 <fileToProcess.ext>"
                exit 11
        fi

        echo "Processing $inputFile, this could take a while..."
        
        touch "$outputFile" || rtError "Could not create output file: $outputFile"
        
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
                        if [[ "${f,,}" == *'/'* ]]; then
                                f="$(echo $f | grep -o '[^/]*$')"
                        fi
                        
                        # Trim whitespaces
                        f="$(echo -e "$f" | tr -d '[:space:]')"
                        #echo "$f" ; echo "${f,,}"

                        # Show only if it starts with "item" and ends with "exe"
                        if [[ "${f,,}" == "item"* ]] && [[ "${f,,}" == *"exe" ]]; then
                                echo -e "$f" >> "$outputFile"
                        fi
                done
        done < "$inputFile"

        echo "Success!"
        echo "File created: $outputFile"
        echo "Creating sorted file..."
        sort -u -o "$outputFileSorted" "$outputFile" && echo "File created: $outputFileSorted"
}

echo "Tavinus Bios List Parser v$PBLVER"

inputFile="$1"
outputFile="$inputFile"".processed.txt"
outputFileSorted="$inputFile"".processed.sorted.txt"

cleanTargets
processFile

echo "All done."
exit 0



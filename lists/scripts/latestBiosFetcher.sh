#!/bin/bash

###################################################################
#
# Hardware ID Latest BIOS Fetcher by Tavinus
#
# To join multiple files
# cat file1 file2 file2 > output.txt
#
# Then sort and remove duplicates
# sort -u -o output.txt output.txt
#
###################################################################

HIDLBFVER=0.0.1
inputFile=''
f=''

rtError() {
        [[ -z "$1" ]] || echo "$1"
        exit 52
}

cleanTargets() {
        rm "$outputFile" 2>/dev/null
        rm "$outputFileSorted" 2>/dev/null
        touch "$outputFile"
}

getLatestVersionName() {
        hid="$1"
        [[ -z "$hid" ]] && return 1
        echo -ne "$hid"$'\t> '
        flink="$(curl -s 'http://sbuservice.samsungmobile.com/BUWebServiceProc.asmx/GetContents?platformID='"$hid"'&PartNumber=AAAA' 2> /dev/null | grep FilePathName)"
        #echo "(1) $flink"
        flink="$(echo "$flink" | cut -d'>' -f 2 | cut -d'<' -f 1 | tr -d '[:space:]')"
        #echo "(2) $flink"
        if [[ "${flink,,}" == "item"* ]] && [[ "${flink,,}" == *"exe" ]]; then
                echo -e "$flink"
                echo -e "$flink" >> "$outputFile"
        else
                echo "FAIL (ignored) > $flink"
        fi
}

processFile() {
        if [[ -z "$inputFile" ]] || [[ ! -f "$inputFile" ]]; then
                echo "Error: File not found: $inputFile"
                echo "Usage: $0 <fileToProcess.ext>"
                exit 11
        fi

        echo "Processing $inputFile, this could take a while..."$'\n'
        
        touch "$outputFile" || rtError "Could not create output file: $outputFile"
        
        # Read and process file
        while IFS="" read -r p || [ -n "$p" ]; do
                # For each line
                for i in $(printf '%s\n' "$p"); do
                        f="$(echo -e "$i" | tr -d '[:space:]')"
                        getLatestVersionName "$f"
                done
        done < "$inputFile"

        echo "Success!"
        echo "File created: $outputFile"
        echo "Creating sorted file..."
        sort -u -o "$outputFileSorted" "$outputFile" && echo "File created: $outputFileSorted" || echo "Error creating file: $outputFileSorted"
}

echo "Tavinus Hardware ID Latest BIOS Fetcher v$HIDLBFVER"

inputFile="$1"
outputFile="$inputFile"".latestBios.txt"
outputFileSorted="$inputFile"".latestBios.sorted.txt"

cleanTargets
processFile

echo "All done."
exit 0



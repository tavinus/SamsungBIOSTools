# List Processing
Lists are processed for installer file names only, one per line.

If you find a BIOS file name in the [main list](../BiosList.txt) with your Hardware ID, you can create a download link for that BIOS and searching for it is not required ([more info here](https://github.com/tavinus/SamsungBIOS#manual-download)).

Multiple lists can be joined with `cat`, then sorted alphabetically (date) and also have duplicates removed (unique).
```
cat file1 file2 file3 > BiosList.txt
sort -u -o BiosList.txt BiosList.txt
```

The script `processBiosList.sh` receives <inputFile.ext> as argument and then creates 2 processed files:
 - inputFile.ext.processed.txt
 - inputFile.ext.processed.sorted.txt

The sorted list tends to be the most usefull. It can also help to determine what File IDs to try on each date interval.

## Lists processed
 - `BIOSItemList (Google Cache Jan 31 2013).txt`
 - `BIOSItemList(112912).xml`

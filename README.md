# SamsungBIOS Tools

***Please note that this document is still a work in progress. Many parts are still missing, but it already has a lot of unique information not found elsewhere.***

Samsung is not known for the quality of its BIOS/UEFI implementations. In fact, for many years they shipped laptops with broken and faulty EFI implementations that would even completely brick the machine in some cases. This is specially bad in the early Windows8 laptops with secure boot. It is also common for the latest version of a BIOS to be worse than its previous versions.

To make things worse, Samsung decided to hide all BIOS downloads from the public, making it even harder to find the files that can help to troubleshoot and recover problematic machines. Nowadays they don't even provide any downloads anymore, except the `SW Update` software that is supposed to automagically download only the latest version of what is needed. There are reports of BIOS updates failing when being run from `SW Update`.

Needless to say, older BIOS versions are even harder to find, but there are some tricks that can help you finding yours.

Most of the data and tools gathered here came from [this thread](http://forum.notebookreview.com/threads/samsung-laptops-roll-back-bios-updates.696197/) in http://forum.notebookreview.com. It is a pretty old and long thread with lots of valuable information. It can also be a bit confusing and overwhelming.

I am creating this repo to organize the data and knowledge from the thread into a smaller and simpler footprint. It is also a way to backup the data from there while adding valuable new information.

I started this because I needed to format a Samsung ATIV Book 6 670Z5E-XD2 that has been "erratic" for some time. It was not accepting a fresh Windows 10 install (or installs and breaks after update). I ended up using CSM (no EFI) to install Windows 10 and that gave me the better results (with the latest BIOS, since older ones did not help). Then you also need to be careful with AMD video drivers, since some of them will also break windows and make it not even boot. This also includes the Windows Update drivers (yep, they also break the machine and they will install even if you turn updates off). I may eventually create an info page about this notebook with all the data (open an issue if you need it).

As of March 2021, the current Windows 10 installer doesn't even load in EFI mode in 2 different Samsung laptops I tried (older versions would run, but break at the end of the installation). 

## Get the latest BIOS first
One of the most important steps is to find out what BIOS family your computer uses. The easiest way is to obtain the latest (recommended) version of your BIOS. This will also provide us with the full filename of the BIOS installer, which is going to be usefull when we are searching for older versions.

### BIOSUpdate.exe
Samsung does not make it easy as they could here. They have a software that downloads the latest version of your recommended BIOS, but it is no longer listed anywhere in their webpage. It is only available through `SW Update` and it will not be offered if you already have the latest BIOS.

One official link is: http://downloadcenter.samsung.com/content/FM/201203/20120306155317061/BIOSUpdate.exe

It is not that hard to find copies on other sites though, just Google "BIOSUpdate.exe" (at your own risk). After running, hit Download to get the latest version file. It is good practice to check if the downloaded version Hardware ID matches the current installed BIOS (read below).

### Linux BIOS downloader script
You can download with [this script](https://github.com/YKonovalov/bios-downloader).

### Manual download
Another option is to find out the current version, use Samsung's webservice to check for a new version and then generate a link with the response FileName.

First find out the current version:

 - Press F2 on Boot to enter the BIOS and see the version
 - Open Windows "System Information" (you can search) and check the version
 - Using `dmidecode` in linux
 - Using `cat /sys/class/dmi/id/bios_version` in linux

After that we will know the Platform ID, which is usually the last 3 letters of the main BIOS String.    
  
So for example, I have a laptop that shows the BIOS Version in "System Information" as:

```
American Megatrends Inc. P05ADG.010.140421.SH, 21/04/2014
```

 - **P05ADG** is the main BIOS model and version
 - **P05** is the version (will search for P04, P03, P02, P01, P00 if looking for older BIOS)
 - **ADG** is the Hardware ID (we will use it to check the latest BIOS file and link)

Now we add the `ADG` Hardware ID into the following URL

```
http://sbuservice.samsungmobile.com/BUWebServiceProc.asmx/GetContents?platformID=[ADD_HARDWARE_ID_HERE]&PartNumber=AAAA
```

So

```
http://sbuservice.samsungmobile.com/BUWebServiceProc.asmx/GetContents?platformID=ADG&PartNumber=AAAA
```

The response is

```xml
<Content xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://sbuservice.samsungmobile.com/">
  <ID>21363</ID>
  <Version>P05ADG</Version>
  <Importance>0</Importance>
  <MsgType>0</MsgType>
  <AutoInstall>0</AutoInstall>
  <ExclusiveInstall>0</ExclusiveInstall>
  <FilePathName>ITEM_20140512_21363_WIN_P05ADG.exe</FilePathName>
  <FileSize>1</FileSize>
  <Downloaded>0</Downloaded>
</Content>
```

We want the node `<FilePathName>`, so we get

```
ITEM_20140512_21363_WIN_P05ADG.exe
```

With this we can download the file by appending it to

```
http://sbuservice.samsungmobile.com/upload/BIOSUpdateItem/[APPEND_HERE]
```

So

```
http://sbuservice.samsungmobile.com/upload/BIOSUpdateItem/ITEM_20140512_21363_WIN_P05ADG.exe
```

The file name also shows us important information that will help when trying to find previous versions:  
  
 - **20140512** - The date when it was published (does not align with BIOS date, but is usually about 15 days later)
 - **21363** - File ID (incremental file number -usually- unique to each file)  
  
So if we were to try and find an older version (eg. P04ADG), we already know its date is going to be before 2014/05/12 and its File ID is lower than 21363.

## Flashing the latest BIOS
If you just want to upgrade your BIOS to the latest version and is currently running a previous version, you may just run the latest Samsung's executable and let it do its thing. It will upgrade the BIOS and MICOM in most cases.

If you are already running the latest BIOS and try to reinstall the Samsung's installer will complain about the version and quit execution. So in this case we will need to get the contents inside the installer so we can run it mannualy. The same applies to older BIOS. **So we can only run the official BIOS installer if we currently have a previous version of the same BIOS installed**. This is important because in many cases we will need to downgrade 1 extra version, to be able to use the official installer of the next version. For example, we manually install `P03ADG`, reboot, and then install `ITEM_20140401_21347_WIN_P04ADG.exe`.

## Extracting Installer files
Samsung uses several vendors for its BIOS, which translates into having to deal with different programs and formats, depending on each machine.

It is kind of a pain to get to the files inside the installer. The easier way is to fetch them from the `%temp%` folder. Depending on your installer this will be more difficult, because some installers only extract the BIOS files after you hit continue and then immediatelly delete the files after using or cancelling execution. This is what happened to me, so I used a script to copy the files continuously. [credits t456](http://forum.notebookreview.com/threads/samsung-laptops-roll-back-bios-updates.696197/page-37#post-10801070)

Download [the script](#) or create `getSamsungFiles.cmd` with this content:

```bat
rmdir /s /q %temp%\SamsungBIOS
mkdir %temp%\SamsungBIOS

:start
robocopy %TEMP%\__Samsung_Update %TEMP%\SamsungBIOS /E
:: Uncomment next line for %programfiles(x86)%\UEFI WinFlash
:: robocopy %programfiles(x86)%\UEFI WinFlash %TEMP%\SamsungBIOS /E
goto start
```

We are now ready to run the installer. Some things to note:

 - If you are in Windows10, right-click the installer > properties > turn ON compatibility mode for Windows 7.
   - This will also prevent Win10 from blocking the unsigned executable.
 - You should run the installer in Administrator mode.
 - You MUST run `getSamsungFiles.cmd` BEFORE the installer and before hitting OK (just double click it).
 - Running the installer in an invalid system should be ok (it should extract and then cancel because it is an invalid system).
 - It does not matter if the installer completes or not. In most cases we do not want it to complete, we just want the files. 
 - Some installers will only extract all files when you tell it to upgrade the BIOS.
 - Some installers use `%programfiles(x86)%\UEFI WinFlash`. In this case you need to fetch it manually or modifiy the script above.


You can open the target folder by simply pasting `%TEMP%\SamsungBIOS` into `run` or windows explorer's address bar.  


If all went fine, you should now have the files in `%TEMP%\SamsungBIOS`. In this case, you can close `getSamsungFiles.cmd` window to stop it.


And then create a folder somewhere (eg. P04ADG) and copy or move the files (`getSamsungFiles.cmd` recreates `%TEMP%\SamsungBIOS` each time it runs, deleting everything).

#### Executables
There are 3 main executables that Samsung uses to flash and one of them will be available in your package:

 - Winflash
 - Afuwin (afuwinx64)
 - SFlash (SFlash64)


You may also download the equivalent GUI for some of them (at your own risk). In this guide we will use an administrator DOS prompt and the flash tool that came with the BIOS package.

#### ROM formats
The BIOS file name will probably be the same as the BIOS ID + extension.  
Eg. The BIOS file inside `ITEM_20140401_21347_WIN_P04ADG.exe` was named as `P04ADG.CAP`  
  
The usual BIOS extensions are:

 - .ROM
 - .CAP
 - .BIN

Any of them should work fine with the flash tool it came with.

## Flashing the extracted BIOS
Here things vary a lot depending on the system. If you were able to actually install a BIOS using the Samsung installer (`ITEM_XXXXX.exe`) you will probably find the commands used inside the file `DebugAppLog.txt`. This is the only way to know exactly what command your BIOS file should use, but in most cases we can try a similar approach to each Flash Utility even without the Log.

Another important thing to mention is that more often than not the problem is NVRAM corruption and not really the BIOS itself (even though a faulty EFI is probably the culprit for the NVRAM corruption). This means that clearing the NVRAM may be enough to fix a faulty Samsung BIOS. Also, manually reflashing the current version may help in many cases, because it may also reset the NVRAM. Some Flash tools have commands to clear the NVRAM, but there could be some risk involved (erasing things you shouldn't). Some people were able to revive semi-bricked laptops with those commands though, so it may be of help in some cases.

---- I AM STILL EDITING ----

## Detective Work
Because there are no recent listings of Samsung's file repository and they are not even listing the downloads in their website anymore, finding an older version can be quite challenging.

The naming convention used by Samsung into the `ITEM_XXX.exe` files ends up being the means on which we can guess possible BIOS file names and then just test if a file exists for download there. In other words, we brute force our way onto finding the older BIOS. It is not pretty, it may take a long time, but it works (most of the times).

Because there is a lot of educated guessing in this process, having more information helps a lot. Have we had a complete list of valid `'ITEM_XXX.exe'` files and we wouldn't have to guess at all. Because of how these file names are structured, it is easier to guess DATES and FILEIDs if we have a more complete list. The more we know, the easier it gets. Also, there are 2 big jumps in FILEID's (on specific dates), which add 10000 each and make the brute force attempts harder (if you try all those 20k extra possible IDs).

Because of this mechanic, I made a bit of an effort to compile a more complete and up to date list of `'ITEM_XXX.exe'` files, indexed by date. Just by looking at the list intervals makes easier to correlate DATES with possible FILEIDs and make a better educated guess in the brute-force search. Trying a smaller interval of dates and IDs makes the search A LOT faster (smaller permutation).

I made a few bash scripts to help me process, gather, filter and sort the data. [They are in the lists folder](lists/)

Because my compilation also includes the latest BIOS for all possible Hardware IDs (in theory), you should be able to do a simple text search for your Hardware ID and find at least one BIOS (the latest as of 2021/04/22). If an older version ever made into the list, you will also find it in the same search.

The file [ITEM_List.txt](ITEM_List.txt) is the compilation of all the data I was able to gather from:

 - **BIOSItemList(112912).xml:** List from Nov 2012 ([link](http://forum.notebookreview.com/threads/samsung-laptops-roll-back-bios-updates.696197/))
 - **BIOSItemList (Google Cache Jan 31 2013).txt:** List from Jan 2013 ([link](http://forum.notebookreview.com/threads/samsung-laptops-roll-back-bios-updates.696197/))
 - **Tavinus01.txt:** I manually copy-pasted all `'ITEM_XXX.exe'` that anyone posted as found in [the 38 pages here](http://forum.notebookreview.com/threads/samsung-laptops-roll-back-bios-updates.696197/)
 - **PermutedLatest_20210422.txt:** I created a list with all possible permutations from AAA to ZZZ and then tried to get the latest BIOS file name to each of them, discarding invalid responses. This is the most complete and recent list of latest BIOS files and adds a lot to the guessing pool.


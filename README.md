# AGDLP_ShareFoldersAndOUstructure

1. Install prerequisite Powershell Module for setting NTFS permissions
https://www.powershellgallery.com/packages/NTFSSecurity/4.2.4

2. Create two files with the following content; Change variables accordingly.

Variables.ps1
```
# Define fileserver share
$dir = "\\FILESERVER\SHARE"

# Define domain controller
$dc = "DC.DOMAIN.TLD"

# Define OU target location
$OUtargetLocation = "OU=GROUPS,OU=DEMO,DC=DOMAIN,DC=TLD"

# Define Group name prefix, for example: ([GroupType]_[Fileserver]_[ShareName])
$grouplocal = 'DLG_FILESERVER_SHARE_'
$groupglobal = 'GG_FILESERVER_SHARE_'

# Define import text file location path
$folderstructure = Get-Content -Path .\folders.txt -Encoding UTF8

# Define NTFS ownership
$domainadmin = "DOMAIN\domain admins"
```

folders.txt
```
Folder1
Folder2
Folder3
Folder4
```

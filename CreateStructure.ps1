## Define variables
. .\variables.ps1

## loading powershell modules
$ADModule='ActiveDirectory'
    if (Get-Module -Name $ADModule) {
        write-host 'Module' $ADModule 'already loaded'
    }
    else {
        Import-Module $ADModule -force
        write-host 'Module' $ADModule 'loaded successfully'
    }


$NTFSModule='NTFSSecurity'
    if (Get-Module -Name $NTFSModule) {
        write-host 'Module' $NTFSModule 'already loaded'
    }
    else {
        Import-Module $NTFSModule -force
        write-host 'Module' $NTFSModule 'loaded successfully'

    }


## Execute folder and group creation
foreach($newfolder in $folderstructure){
    # Generate path to folders
    $folderpath = "$dir\$newfolder"
    # Generate groupnames
    $groupnamelocalread = ("$grouplocal"+$newfolder+"_r").ToLower()
    $groupnameglobalread = ("$groupglobal"+$newfolder+"_r").ToLower()
    $groupnamelocalwrite = ("$grouplocal"+$newfolder+"_w").ToLower()
    $groupnameglobalwrite = ("$groupglobal"+$newfolder+"_w").ToLower()


if( -Not (Test-Path -Path "$folderpath" ) )
{
    # Create folders on fileserver share
    New-Item -ItemType directory -Path "$folderpath".Tolower() | Out-Null
    Write-Host "folder $folderpath created"

    # Create AD write groups (DLG and GG)
    New-ADGroup -server "$dc" -GroupScope global -Name "$groupnameglobalwrite" -Path "$OUtargetLocation" -Description "global permission to write on $folderpath" 
    New-ADGroup -server "$dc" -GroupScope domainlocal -Name "$groupnamelocalwrite" -Path "$OUtargetLocation" -Description "local permission to write on $folderpath"  
    # Group nesting AD write groups (DLG and GG)
    $TempReadGroup = get-adgroup -server $dc -Identity ("$groupnameglobalwrite")
    Add-ADGroupMember -Identity ("$groupnamelocalwrite") -Members $TempReadGroup -Server $dc
    
    #Create AD read groups (DLG and GG)
    New-ADGroup -server "$dc" -GroupScope global -Name "$groupnameglobalread" -Path "$OUtargetLocation" -Description "global permission to read on $folderpath" 
    New-ADGroup -server "$dc" -GroupScope domainlocal -Name "$groupnamelocalread" -Path "$OUtargetLocation" -Description "local permission to read on $folderpath"  
    # Group nesting AD read groups (DLG and GG)
    $TempReadGroup = get-adgroup -server $dc -Identity ("$groupnameglobalread")
    Add-ADGroupMember -Identity ("$groupnamelocalread") -Members $TempReadGroup -Server $dc
    
    # Set NTFS permissions on fileserver share  
    Write-Host "Adding NTFS Permissions"
    # Set owner
    $folderpath | Set-NTFSOwner -Account "$domainadmin"
    Write-Host "New Owner on $NewFolder is $domainadmin "
    Write-Host "Addin other NTFS Permissions on $NewFolder "
    # Apply write permissions
    Add-NTFSAccess -Path "$folderpath" -Account ("$groupnamelocalwrite") -AccessRights ReadData,CreateFiles,Createdirectories,ReadExtendedAttributes,WriteExtendedAttributes,DeleteSubdirectoriesandFiles,ReadAttributes,WriteAttributes,ReadPermissions,ExecuteFile -AppliesTo ThisFolderSubfoldersAndFiles
    # Apply read permissions
    Add-NTFSAccess -Path "$folderpath" -Account ("$groupnamelocalread") -AccessRights Read,ReadAndExecute,ListDirectory -AppliesTo ThisFolderSubfoldersAndFiles
    Write-Host  "NTFS Permissions set!"   
    # Show all NTFS permissions on folder in console
    Get-NTFSAccess -Path "$folderpath" | Format-Table -AutoSize -Wrap
     
} 
else 
{
    ## Nothing to be done here..
    Write-Host "$newfolder Folder already exists, nothing will be created!" -ForegroundColor Yellow
    
}
 
}
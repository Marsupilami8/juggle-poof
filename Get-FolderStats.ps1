<#
.SYNOPSIS

Returns the size of each folder in a specified base path.

.DESCRIPTION

This function will get the folder size in GB of directories found in a base path parameter. 
The base path parameter defaults to the local root path. You can also specify a specific folder.

.PARAMETER BasePath

Specify the base path of the child folders you want to obtain stats on. Defaults to the working 
directory.

.PARAMETER Total

Sets the boolean switch to TRUE for just returning the total size in GB for the chosen folder path.

.EXAMPLE

PS C:\scripts\Get-FolderStats.ps1 C:\example1\

Calculating folder sizes ...

FolderName              Size(GB)
----------              --------
Ramen Noodle            0.047
Quickbooks              0.104
Virtual Machines        92.371
Visual Studio 2012      0.000
Zune                    0.000

.EXAMPLE

PS C:\scripts\Get-FolderStats.ps1 C:\example2\ -Total

Calculating folder sizes ...
Total Size: 95 GB

.INPUTS

Path to directory folder. See Parameters for details.

.OUTPUTS

Default just outputs folder name and corresponding sizes of directories in GB up to three decimal places.
With the Total switch turned on, the output just returns the total size of the folder path.

.LINK

TBD

.TODO

Include ouput stats for number of files/folders for each root folder.

.NOTES
   
Inspired by the work of:

https://www.gngrninja.com/script-ninja/2016/5/24/powershell-calculating-folder-sizes
https://devblogs.microsoft.com/scripting/getting-directory-sizes-in-powershell/

    -----------------------------------------------------------------------------------
    Author:  Marsupilami8
    Date:    2022-12-17
    Version: 1.0
#>

[CmdletBinding()]
param (

    [parameter(Position=0, Mandatory=$false, ParameterSetName="BasePath")]
    $BasePath=(Get-Location).Path,
    [Switch] 
    $Total = $false
  
)

begin {

    #Create script level objects to store folder info and sizes
    [System.Collections.ArrayList] $script:folderList = @()
    [UInt64] $script:totalSize = 0

    Write-Host "Calculating folder sizes ..."
}

process {

     # Get a list of all the directories in the base path you are looking for.
     $Folders = Get-ChildItem $BasePath -Directory -Force

    #Go through each folder in the base path.
    ForEach ($folder in $Folders) {

        #Clear out the variables used in the loop.
        $folderSize = $null
        $folderObject = $null
                
        $folderSize = Get-Childitem -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue       
  
        #Create a custom object
        $folderObject = [PSCustomObject]@{
            FolderName    = $folder.BaseName 
            'Size(GB)'    = "{0:0.000}" -f ($folderSize.Sum / 1GB)
        } 

        $script:folderList.Add($folderObject) | Out-Null
        $script:totalSize +=  ($folderObject).'Size(GB)'
        
    }
}

end {
    
 if ( $Total ) {
    Write-Host "Total Size: $script:totalSize GB"
  }
  else {
    return $script:folderList 
  }

}

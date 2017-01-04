function Find-Files {
<#
.Synopsis
   Grep like search
.AUTHOR
    Kim White (kim.white@taos.za.net)
.VERSION
    1.0
.DESCRIPTION
   Grep like search with colourising
    - Green - File Path
    - Cyan - Result in File
    - Yellow - Line Number
.EXAMPLE
   Find-Files -SearchPath C:\Path\To\Search\In -Text "Test you are looking for"
.EXAMPLE
   Find-Files -SearchPath C:\Path\To\Search\In -Text "Test you are looking for" -ResultsFile
#>
param
    (
    [Parameter(Mandatory=$true)]
        [string]$SearchPath,
    [Parameter(Mandatory=$true)]
        [string]$Text,
    [Parameter(Mandatory=$false)]
        [string]$ResultsFile=""
    )
$Files = Get-ChildItem -Path $SearchPath -Recurse -Filter "*.*" | Where-Object { $_.Attributes -notlike "Directory*"}
$Files | Select-String -Pattern "$Text" | ForEach-Object {Write-host -NoNewline -ForegroundColor Green "$($_.Path) :" ; Write-host -NoNewline -ForegroundColor Cyan ": $($_.line) :" ; Write-host -ForegroundColor Yellow ": $($_.LineNumber)"  }
if ( $ResultsFile -ne "" )
{
    del $ResultsFile
    $Files | Select-String -Pattern "$Text" | ForEach-Object { "$($_.Path),$($_.line),$($_.LineNumber)" | Export-Csv -Path $ResultsFile }
    #Add-content $ResultsFile -Value "$($_.Path),$($_.line),$($_.LineNumber)"  }
}
}
Find-Files -SearchPath C:\Gitwork\ip-ranges -Text "dc01" -ResultsFile C:\temp\test.txt
Get-Content C:\temp\test.txt
#Clean-up extra subtitles after merge/update from source One Pace repo
#Currently hardcoded to remove non-english subtitle files, plan to update to allow user to specify what language to keep
function Remove-ExtraLanguages {
    param (
        #Plan to add param to allow user to select language to keep
    )

    #Getting folders for quick removal of raw subtitle files. Will only need final files
    $mainPath = Join-Path -Path $PSScriptRoot -ChildPath "main"
    $subFolders = Get-ChildItem -Path $mainPath -Directory
    foreach ($folder in $subFolders) {
        #If not named "Release", remove
        if($folder.Name -notmatch "Release") {
            Remove-Item -Path $folder.FullName -Recurse
        } else {
            #remove extra languages from final sub files
            $finalSubPath = Join-Path -Path $folder.FullName -ChildPath "Final Subs"
            $subFiles = Get-ChildItem -Path $finalSubPath
            foreach ($file in $subFiles) {
                if ($file.Name -notlike "*].ass") {
                    #English language subs always end in "].ass"
                    Remove-Item -LiteralPath $file.FullName -Force -Recurse
                }
            }
        }
    }

    #might as well remove the extra project files as well
    Get-ChildItem -Path $mainPath -File | Remove-Item
}

#OnePace Dubbed videos already include on-screen text subs, we can remove those subs
#This function does not behave as well as I hoped to remove One Pace dubbed files. Algorithm needs to be re-thought
function Remove-OnePaceSubs {
    param (
        # Location of One Pace/Muhn Pace videos
        [Parameter(Mandatory)]
        [string]
        $videoPath,
        # Location of Sub files
        [Parameter()]
        [string]
        $mainPath
    )

    #check if $mainPath was provided, set to default if not
    if ($null -eq $mainPath) {
        $mainPath = Join-Path -Path $PSScriptRoot -ChildPath "main"
    }

    #get sub files from working directory
    $subFiles = Get-ChildItem -Path $mainPath -File -Recurse | Where-Object {($_.Extension -eq ".ass")}

    #Get all "official" One Pace files
    $onePaceEps = Get-ChildItem -Path $videoPath -File -Recurse | Where-Object {($_.Name -like "*One*") -and ($_.Extension -eq ".mp4")}

    #loop through One Pace eps and remove matching subtitle files
    foreach ($opEp in $onePaceEps) {
        $epNum = $opEp.Name.Substring(11,($opEp.Name.IndexOf(']',10)-11)) #isolate chapter number from title. Char 11 to second ]. Get difference for length
        Write-host $epNum
        foreach ($file in $subFiles) {
            $fileNum = $file.Name.Substring(11,($file.Name.IndexOf(']',10)-11))
            
            if ($fileNum -eq $epNum) {
                Remove-Item -LiteralPath $file.FullName -Force
            }
        }
    }
}

function Sync-FileNames {
    param (
        # Video File location
        [Parameter(Mandatory)]
        [string]
        $videoPath,
        # Subtitle file path, will be set to default location if not passed
        [Parameter()]
        [string]
        $mainpath
    )

    #check if $mainPath was provided, set to default if not
    if ($null -eq $mainPath) {
        $mainPath = Join-Path -Path $PSScriptRoot -ChildPath "main"
    }
    
    #get sub files from working directory
    $subFiles = Get-ChildItem -Path $mainPath -File -Recurse | Where-Object {($_.Extension -eq ".ass")}

    #Get all Muhn Pace files
    $muhnPaceEps = Get-ChildItem -Path $videoPath -File -Recurse | Where-Object {($_.Name -like "*Muhn*") -and ($_.Extension -eq ".mp4")}
    
    foreach ($file in $subFiles) {
        $start = $file.Name.IndexOf(']',10)+2 #Name start point
        $length = $file.Name.IndexOf('[',$start) - $start #length of full name
        $subName = $file.Name.Substring($start,$length-1) #isolate sub ep title. Char 11 to second ]

        foreach ($mpEp in $muhnPaceEps) {
            $start = $mpEp.BaseName.IndexOf(']')+2 #Name start point
            $epName = $mpEp.BaseName.Substring($start) #isolate ep title

            if ($subName -eq $epName) {
                $newName = $mpEp.BaseName + ".forced.ass" #generate new subtitle file name to match video file name
                Rename-Item -LiteralPath $file.FullName -NewName $newName
            }
        }

    }

}

#todo
#add feature to move completed subs to video directory
#gen simple interface
#gen forced subtitles for plex
#handle different regions

Sync-FileNames
#Remove-OnePaceSubs
#Remove-ExtraLanguages

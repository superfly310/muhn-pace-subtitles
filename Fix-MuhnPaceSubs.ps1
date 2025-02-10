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
function Remove-OnePaceSubs {
    param (
        # Location of One Pace/Muhn Pace videos
        [Parameter(Mandatory)]
        [string]
        $videoPath
    )

    #get sub files from working directory
    $subFiles = Get-ChildItem -Path $mainPath -File -Recurse | Where-Object {($_.Extension -eq ".ass")}

    #Get all "official" One Pace files
    $onePaceEps = Get-ChildItem -Path $videoPath -File -Recurse | Where-Object {($_.Name -like "*One*") -and ($_.Extension -eq ".mp4")}

    #loop through One Pace eps and remove matching subtitle files
    foreach ($opEp in $onePaceEps) {
        $epNum = $opEp.Name.Substring(10,($opEp.Name.IndexOf(']',10))) #grab identifier to link video file to sub file, ie [OnePace][1060-1063]
        foreach ($file in $subFiles) {
            if ($file.Name -like "$epNum") {
                Remove-Item -LiteralPath $file.FullName
            }
        }
    }
}

Remove-OnePaceSubs
#Remove-ExtraLanguages

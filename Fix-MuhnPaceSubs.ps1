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





#Remove-ExtraLanguages

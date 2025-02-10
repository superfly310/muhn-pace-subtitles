#Clean-up extra subtitles after merge/update from source One Pace repo
#Currently hardcoded to remove non-english files, plan to update to allow user to specify what language to keep
function Remove-ExtraLanguages {
    param (
        #Plan to add param to allow user to select language to keep
    )

    #Getting folders for quick removal of raw subtitle files. Will only need final files
    $mainPath = Join-Path -Path $PSScriptRoot -ChildPath "main"
    $subFolders = Get-ChildItem -Path $mainPath -Directory
    foreach ($folder in $subFolders) {
        if($folder.Name -notmatch "Release") {
            Remove-Item -Path $folder.FullName -Recurse
        }
    }
}

Remove-ExtraLanguages

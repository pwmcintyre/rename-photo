# modified from 
# https://til.secretgeek.net/powershell/rename_photos.html
# 
# usage example:
# ls *.jpg | % { Rename-Photo $_.FullName "iPhoneLB" "Martinique" }

function move-photo(
	[ValidateScript({Test-Path $_})][string]$source,
	[ValidateScript({Test-Path $_})][string]$destination
){

	if ($source -eq "") {
		write-host "source not found" -foregroundcolor "red"
		return
	}

	if ((Test-Path $source) -eq $false) {
		write-host "source not found: $source" -foregroundcolor "red"
		return
	}

	$null = [reflection.assembly]::LoadWithPartialName("System.Drawing")
	$pic = New-Object System.Drawing.Bitmap($source)

	# via http://stackoverflow.com/questions/6834259/how-can-i-get-programmatic-access-to-the-date-taken-field-of-an-image-or-video
	$bitearr = $pic.GetPropertyItem(36867).Value # Date Taken

	$pic.Dispose()

	if ($bitearr -ne $null) {

		$string = [System.Text.Encoding]::ASCII.GetString($bitearr)
		$exactDate = [datetime]::ParseExact($string,"yyyy:MM:dd HH:mm:ss`0",$Null)

	} else {

		# we could not extract an EXIF "Date Taken".
		# perhaps we can one of these dates instead.
		# CreationTime              Property       datetime CreationTime {get;set;}
		# CreationTimeUtc           Property       datetime CreationTimeUtc {get;set;}
		# LastAccessTime            Property       datetime LastAccessTime {get;set;}
		# LastAccessTimeUtc         Property       datetime LastAccessTimeUtc {get;set;}
		# LastWriteTime             Property       datetime LastWriteTime {get;set;}
		# LastWriteTimeUtc          Property       datetime LastWriteTimeUtc {get;set;}
		dir $source | % { $exactDate = $_.LastWriteTime; }
	}

	# build destination path
	$item = Get-Item $source
	$newpath = [IO.Path]::Combine( $destination, ("{0:yyyy}" -f $exactDate), ("{0:yyyy-MM-dd}" -f $exactDate), $item.Name )

	# troubleshooting
	# write-host "source: $source"
	# write-host "exactDate: $exactDate"
	# write-host ("{0:yyyy}" -f $exactDate)
	# write-host ("{0:yyyy-MM-dd}" -f $exactDate)
	write-host $newpath

	# rename-item $source $newpath

}

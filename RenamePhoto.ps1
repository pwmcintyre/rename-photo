# modified from 
# https://til.secretgeek.net/powershell/rename_photos.html
# 
# usage example:
#   Import-Module C:\Users\peter\move.ps1
#   ls | Move-Photo -destination ../dest

function Move-Photo(

	# ref: https://blog.simonw.se/powershell-functions-and-parameter-sets/
	[parameter( ParameterSetName = 'Path', Mandatory )]
	[parameter( ParameterSetName = 'LiteralPath' )]
	[ValidateScript({Test-Path $_})]
	[string] $destination = ".",

	[parameter(
		Mandatory,
		ParameterSetName  = 'Path',
		Position = 0,
		ValueFromPipeline,
		ValueFromPipelineByPropertyName
	)]
	[ValidateNotNullOrEmpty()]
	[SupportsWildcards()]
	[string[]] $Path,

	[parameter(
		Mandatory,
		ParameterSetName = 'LiteralPath',
		Position = 0,
		ValueFromPipelineByPropertyName
	)]
	[ValidateNotNullOrEmpty()]
	[Alias('PSPath')]
	[string[]] $LiteralPath

){
	BEGIN {

		# troubleshooting
		# write-host $destination

	}
	PROCESS
	{

		# resolve paths
		# ref: https://4sysops.com/archives/process-file-paths-from-the-pipeline-in-powershell-functions/
		if ($PSCmdlet.ParameterSetName -eq 'Path') {
			$resolvedPaths = Resolve-Path -Path $Path | Select-Object -ExpandProperty Path
		} elseif ($PSCmdlet.ParameterSetName -eq 'LiteralPath') {
			$resolvedPaths = Resolve-Path -LiteralPath $LiteralPath | Select-Object -ExpandProperty Path
		}

		# process
		$done = 0
		foreach ($source in $resolvedPaths) {

			# last write time is good enough
			$date = ( Get-Item $source ).LastWriteTime

			# build destination path
			$item = Get-Item $source
			$newpath = [IO.Path]::Combine( $destination, ("{0:yyyy}" -f $date), ("{0:yyyy-MM-dd}" -f $date), $item.Name )

			# troubleshooting
			# write-host "source: $source"
			# write-host "date: $date"
			# write-host ("{0:yyyy}" -f $date)
			# write-host ("{0:yyyy-MM-dd}" -f $date)
			# write-host $newpath

			# move
			mkdir -force (Split-Path $newpath) | Out-Null
			# rename-item $source $newpath
			copy-item $source $newpath -Force

			$done++
			Write-Progress -Activity 'copying ...' -Status $newpath -PercentComplete ( ( $done / $resolvedPaths.Length ) * 100 )

		}
	}
	END {}

}

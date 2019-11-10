# Moves files into a path given their lastWriteDate:
# from: file.ext
#   to: yyyy/yyyy-MM-dd/file.ext
# 
# modified from 
# https://til.secretgeek.net/powershell/rename_photos.html
# 
# usage example:
# ls *.jpg | Move-Photo -Destination ~/Desktop

function Move-Photo(

	# ref: https://blog.simonw.se/powershell-functions-and-parameter-sets/
	[parameter( ParameterSetName = 'Path', Mandatory )]
	[parameter( ParameterSetName = 'LiteralPath' )]
	[ValidateScript({Test-Path $_})]
	[string] $Destination = ".",

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

		write-host $Destination

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
		foreach ($source in $resolvedPaths) {

			# last write time is good enough
			$date = ( Get-Item $source ).LastWriteTime

			# build destination path
			$item = Get-Item $source
			$newpath = [IO.Path]::Combine( $Destination, ("{0:yyyy}" -f $date), ("{0:yyyy-MM-dd}" -f $date), $item.Name )

			# ensure folder exists
			mkdir -force (Split-Path $newpath) | Out-Null

			# move
			# rename-item $source $newpath
			copy-item $source $newpath -Force

		}
	}
	END {}

}

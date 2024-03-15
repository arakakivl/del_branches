# All script parameters and arguments.
param (
	[string]$repo = ".\"
)

# Utilitary functions
function Die {
	param (
		[string]$message = ""
	)

	if ($message -ne "") { Write-Host $message }
	Exit
}

# First, verifying directory existence.
if (-not (Test-Path -Path $repo)) {
	Die -message "The directory $repo could not be found."
}

cd $repo
$branches = git branch 2> $null | Out-String

# Now, verifying if $repo is really a git repository.
# Handling any errors thrown in the above command. Furthermore, redirecting error output.
Switch ($LASTEXITCODE)
{
	0 { }
	128 {
		Die "An error has occured ($LASTEXITCODE): there's no git repository in $repo."
	}
	default {
		Die "An unknown error has occured ($LASTEXITCODE)."
	}
}


# Deleting branches that are not in use (actually this attempt would result in an error anyway).
# Supressing output by redirecting "standard output" into null.
ForEach ($branch in $($branches -split "`r`n")) {
	if ($branch -notlike "*deploy_homolog" -and ($branch.Trim() -ne "") -and $branch[0] -ne "*") {
		Write-Host Deleting branch $branch.Trim()
		git branch -D $branch.Trim() 1> $null
	}
}

Write-Host "Done!"

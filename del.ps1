<#
	.SYNOPSIS
		Utility for deleting local and not active branches.
	.DESCRIPTION
		Deletes not active local branches or specified branches in the ignore file.
  	.PARAMETER repo
		Specifies the repository directory. If no one is provided, then ".\" is used.
        .PARAMETER force
 		Specifies whether non-pushed branches should be deleted.
	.EXAMPLE
		PS> .\del.ps1
		Deleting branch mysql_provider
		Deleting branch local2
		Done!
#>

# All script parameters and arguments.
param (
	[string]$repo = ".\",
	[switch]$force
)

# Utilitary functions
function Die {
	param (
		[string]$message = ""
	)

	if ($message -ne "") { Write-Host -ForeGroundColor Red $message `n }
	Exit
}

# First, verifying directory existence.
if (-not (Test-Path -Path $repo)) {
	Die -message "The directory $repo could not be found."
}

# Storing actual location
$pwd = Get-Location

# Changing directory
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
	$branch = $branch.Trim()
	if ($branch[0] -ne "*" -and ($branch -ne "")) {
		Write-Host "Deleting branch $branch"
		if ($force) {
			git branch -D $branch 1> $null
		} else {
			git branch -d $branch 2>&1> $null
			if ($LASTEXITCODE -eq 1) {
				Write-Host -ForegroundColor Yellow "Branch $branch could not be deleted because it has not pushed commits."
				Write-Host -ForegroundColor Yellow "Use -force flag to delete it.`n"
			}
		}
	}
}

# Going back to previous directory
cd $pwd
Write-Host "Done!`n"

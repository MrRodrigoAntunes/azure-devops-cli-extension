function projectExists{
    param(
        [String]$org,
        [String]$projectName
    )


    Write-Host "`nCheck if project with name $($projectName) exists. . . " 
    $projectExists = az devops project list --org $org --query "[?name == '$($projectName)'].id" -o json | ConvertFrom-Json

    if (!$projectExists) { Write-Host "Project not found" }
    else { Write-Host "Project found with ID $($projectExists.id)" }

    return $projectExists
}

function createProject{
    param(
        [String]$org,
        [String]$projectName,
        [String]$process,
        [String]$sourceControl,
        [String]$visibility
    )


    Write-Host "`nCreating project with name $($projectName) . . . " 
    $project = az devops project create --org $org --name $projectName --process $process --source-control $sourceControl --visibility $visibility -o json | ConvertFrom-Json
    Write-Host "Created project with name $($project.name) and Id $($project.id)"
    return $project.id
}

function repoExists{
    param(
        [String]$org,
        [String]$projectID,
        [String]$repoName
    )

    Write-Host "`nCheck if repository with name $($repoName) already exists. . . " 
    $repo = az repos list --org $org -p $projectID --name $repoName --query "[?name == '$($repoName)'].id" -o json | ConvertFrom-Json
    
    if (!$repo) { Write-Host "Repo not found" }
    else { Write-Host "Repo found with ID $($repo.id)" }

    return $repo
}

function createRepo{
    param(
        [String]$org,
        [String]$projectID,
        [String]$repoName
    )

    Write-Host "`nCreating repository with name $($repoName) . . . " 
    $repo = az repos create --org $org -p $projectID --name $repoName -o json | ConvertFrom-Json
    Write-Host "Created repository with name $($repo.name) and Id $($repo.id)"
    return $repo.id
}

function importRepo{
    param(
        [String]$org,
        [String]$projectID,
        [String]$repoID,
        [String]$repoToImport,
        [String]$repoType
    )
    if($repoToImport -and ($repoType -eq 'Public')){
        Write-Host "`nImporting repository from url $($repoToImport)" 
        $importRepo = az repos import create --org $org -p $projectID -r $repoID --git-url $repoToImport -o json | ConvertFrom-Json
        Write-Host "Repo imported with Status $($importRepo.status)"
    }
    else {
        Write-Host "Private repo import failed!"
    }
}

function publishCodeWiki{
    param(
        [String]$org,
        [String]$projectID,
        [String]$repo,
        [String]$wikiName,
        [String]$path,
        [String]$wikiType,
        [String]$branch
    )
    if ($wikiType -eq 'codewiki' -and $path -and $branch){
        $createCodeWiki = az devops wiki create --name $wikiName --type codewiki --version $branch --mapped-path $path -r $repo --org $org -p $projectID -o json | ConvertFrom-Json
        Write-Host "New code wiki published with ID : $($createCodeWiki.id)"
    }
    else {
        $createProjectWiki = az devops wiki create --name $wikiName --type projectwiki -org $org -p $projectID -o json | ConvertFrom-Json
        Write-Host "New project wiki created with ID : $($createProjectWiki.id)"
    }
}

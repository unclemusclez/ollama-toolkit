#!/bin/bash
# Array of GitHub repository URLs (replace with your actual repo URLs)

repos=(
### Insert links per line here, enclosed in ""
## "http://github.com/example/project1.git"
## "http://github.com/example/project2.git"
)

mkdir -p gitdocs
cd gitdocs

git init

# Loop through each repository URL
for repo in "${repos[@]}"; do

  # Extract the repository name from the URL
  repo_name=$(basename "$repo" .git)

  # Clone the repository as a submodule within the directory
  git clone --no-checkout --depth 1 "$repo" $repo_name

  cd $repo_name
  git sparse-checkout set --no-cone '!/*' '/docs' '/Docs' '/doc' '/DOCS' '/Doc' '/DOC' '/documents' '/Documents' '/*.md' '/tutorials' '/examples' '/content' '/guides' '/*.txt' '/*.sh'
  git read-tree -mu HEAD

  # Return to the parent directory
  cd ..

done

# Update project's .gitmodules to register the added submodules
# (This assumes you ran this script within your main Git project)

echo "[submodule \"$repo_name\"]
path = ./$repo_name
url = $repo" >> .gitmodules 

# Initialize and update all submodules
git submodule init
git submodule update
git sparse-checkout disable
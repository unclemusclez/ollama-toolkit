#!/bin/bash
# Array of GitHub repository URLs (replace with your actual repo URLs)

repos=(
)
mkdir -p gitdocs
cd gitdocs

git init

# Create a directory for submodules if it doesn't exist
mkdir -p submodules

# Loop through each repository URL
for repo in "${repos[@]}"; do

  # Extract the repository name from the URL
  repo_name=$(basename "$repo" .git)

  # Clone the repository as a submodule within "submodules/" directory
  git clone --no-checkout --depth 1 "$repo" submodules/$repo_name

  cd submodules/$repo_name
  git sparse-checkout set docs Docs doc DOCS Doc DOC documents Documents README.md *.md
  git checkout

  # Return to the parent directory
  cd ..

done

# Update project's .gitmodules to register the added submodules
# (This assumes you ran this script within your main Git project)

echo "[submodule \"$repo_name\"]
path = submodules/$repo_name
url = $repo" >> .gitmodules 

# Initialize and update all submodules
git submodule init
git submodule update
git sparse-checkout disable
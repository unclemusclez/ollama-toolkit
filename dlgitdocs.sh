#!/bin/bash
# export GIT_DISCOVERY_ACROSS_FILESYSTEM=0

# Array of GitHub repository URLs (replace with your actual repo URLs)
GIT_REPOS=(
## Insert links per line here, enclosed in ""
# "http://github.com/example/project1.git"
# "http://github.com/example/project2.git"
)

# Array of GitHub safe directories paths for multi-user directories(replace with your actual directories)
# SAFE_DIRS=(
## Insert links per line here, enclosed in ""
#   # "/mnt/example/data/docs/gitdocs"
# )

GITDOCS_DIR=$PWD/gitdocs
LOGFILE=$GITDOCS_DIR/.log

printf "Creating and changing directory to  $GITDOCS_DIR"
echo "Creating and changing directory to $GITDOCS_DIR" > $LOGFILE
mkdir -p gitdocs
cd gitdocs
git init

# Loop through each repository URL
printf "Looping through each repository URL"
echo "Looping through each repository URL" >> $LOGFILE
for repo in "${GIT_REPOS[@]}"; do

  # Extract the repository name from the URL
  repo_name=$(basename "$repo" .git)
  printf "Adding git safe directories"
  echo "Adding git safe directories" >> $LOGFILE
  for safe_dir in "${SAFE_DIRS[@]}"; do
    git config --global --add safe.directory $safe_dir/$repo_name
    printf "Git safe directory added at $safe_dir/$repo_name"
    echo "Git safe directory added at $safe_dir/$repo_name" >> $LOGFILE
  done

  # Clone the repository as a submodule within the directory
  printf "Clone the repository as a submodule within the directory and changing directory to $repo_name"
  echo "Clone the repository as a submodule within the directory and changing directory to $repo_name" >> $LOGFILE

  git clone --no-checkout --depth 1 "$repo" $repo_name

  # Change to Repo directory and sparse checkout
  printf "Sparsing Checkout and setting HEAD"
  echo "Sparsing Checkout and setting HEAD" >> $LOGFILE 

  cd $repo_name
  git sparse-checkout set --no-cone '!/*' '/docs' '/Docs' '/doc' '/DOCS' '/Doc' '/DOC' '/documents' '/Documents' '/*.md' '/tutorials' '/examples' '/content' '/guides' '/*.txt' '/*.sh'
  git read-tree -mu HEAD

# Return to the parent directory
 cd ..

# Update project's .gitmodules to register the added submodules
# (This assumes you ran this script within your main Git project)
  printf "Update project's .gitmodules to register the added submodules"
  echo "Update project's .gitmodules to register the added submodules" >> $LOGFILE 
  

  echo "[submodule $repo_name]
  path = ./$repo_name
  url = $repo" >> .gitmodules

  
  printf "Echo'd Submodule"
  echo "Echo'd Submodule" >> $LOGFILE 
done

# Initialize and update all submodules
git submodule init
git submodule update
git sparse-checkout disable
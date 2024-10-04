#!/bin/bash
# export GIT_DISCOVERY_ACROSS_FILESYSTEM=0

# Array of GitHub repository URLs (replace with your actual repo URLs)
REPOS=(

)

SPARSED_REPOS=(
## Insert links per line here, enclosed in ""
# "http://github.com/example/project1.git"
# "http://github.com/example/project2.git"
)

# Array of GitHub safe directories paths for multi-user directories(replace with your actual directories)
# SAFE_DIRS=(
## Insert links per line here, enclosed in ""
#   # "/mnt/example/data/docs/gitdocs"
# )

timestamp() {
  date +"%T" # current time
}
GITDOCS_DIR=$PWD/gitdocs
LOGFILE=$GITDOCS_DIR/.log

echo -e "$(timestamp) ----------DLGitDocs---------\n" > $LOGFILE
printf "\nCreating and changing directory to  $GITDOCS_DIR\n"
echo -e "$(timestamp) Creating and changing directory to $GITDOCS_DIR\n" >> $LOGFILE
mkdir -p $GITDOCS_DIR
cd $GITDOCS_DIR
git init

# Loop through each repository URL
printf "\nLooping through each repository URL\n"
echo -e "$(timestamp) Looping through each repository URL\n" >> $LOGFILE
for repo in "${REPOS[@]}"; do
# Extract the repository name from the URL
  repo_name=$(basename "$repo" .git)
  printf "\nAdding git safe directories\n"
  echo -e "$(timestamp) Adding git safe directories\n" >> $LOGFILE
  for safe_dir in "${SAFE_DIRS[@]}"; do
    git config --global --add safe.directory $safe_dir/$repo_name
    printf "\nGit safe directory added at $safe_dir/$repo_name\n"
    echo -e "$(timestamp) Git safe directory added at $safe_dir/$repo_name\n" >> $LOGFILE
  done

  # Clone the repository as a submodule within the directory
  printf "\nClone the repository as a submodule within the directory and changing directory to $repo_name\n"
  echo -e "$(timestamp) Clone the repository as a submodule within the directory and changing directory to $repo_name\n" >> $LOGFILE

  git clone --depth 1 "$repo" $GITDOCS_DIR/$repo_name
# Update project's .gitmodules to register the added submodules
# (This assumes you ran this script within your main Git project)
  printf "\nUpdate project's .gitmodules to register the added submodules\n"
  echo -e "$(timestamp) Update project's .gitmodules to register the added submodules\n" >> $LOGFILE 
  

  echo -e "[submodule \"$repo_name\"]
  path = ./$repo_name
  url = $repo\n" > .gitmodules

  
  printf "\nEcho'd Submodule\n"
  echo -e "$(timestamp) Echo'd Submodule\n" >> $LOGFILE 
done
cd $GITDOCS_DIR
# Loop through each repository URL
printf "\nLooping through each SPARSED repository URL\n"
echo -e "$(timestamp) Looping through each repository URL\n" >> $LOGFILE
for repo in "${SPARSED_REPOS[@]}"; do

  # Extract the repository name from the URL
  repo_name=$(basename "$repo" .git)
  printf "\nAdding git safe directories\n"
  echo -e "$(timestamp) Adding git safe directories\n" >> $LOGFILE
  for safe_dir in "${SAFE_DIRS[@]}"; do
    git config --global --add safe.directory $safe_dir/$repo_name
    printf "\nGit safe directory added at $safe_dir/$repo_name\n"
    echo -e "$(timestamp) Git safe directory added at $safe_dir/$repo_name\n" >> $LOGFILE
  done

  # Clone the repository as a submodule within the directory
  printf "\nClone the repository as a submodule within the directory and changing directory to $repo_name\n"
  echo -e "$(timestamp) Clone the repository as a submodule within the directory and changing directory to $repo_name\n" >> $LOGFILE

  git clone --no-checkout --depth 1 "$repo" $GITDOCS_DIR/$repo_name

  # Change to Repo directory and sparse checkout
  printf "\nSparsing Checkout and setting HEAD\n"
  echo -e "$(timestamp) Sparsing Checkout and setting HEAD\n" >> $LOGFILE 

  cd $repo_name
  git sparse-checkout set --no-cone '!/*' '/docs' '/Docs' '/doc' '/DOCS' '/Doc' '/DOC' '/documents' '/Documents' '/*.md' '/tutorials' '/examples' '/content' '/guides' '/*.txt' '/*.sh'
  git read-tree -mu HEAD

# Return to the parent directory
 cd ..

# Update project's .gitmodules to register the added submodules
# (This assumes you ran this script within your main Git project)
  printf "\nUpdate project's .gitmodules to register the added submodules\n"
  echo -e "$(timestamp) Update project's .gitmodules to register the added submodules\n" >> $LOGFILE 
  

  echo -e "[submodule \"$repo_name\"]
  path = ./$repo_name
  url = $repo\n" >> .gitmodules

  
  printf "\nEcho'd Submodule\n"
  echo -e "$(timestamp) Echo'd Submodule\n" >> $LOGFILE 
done

# Initialize and update all submodules
git submodule init
git submodule update
git sparse-checkout disable
# DLGitDocs

## Bash Script for Cloning Documentation as Git Submodules

This Bash script automates the process of cloning documentation from multiple GitHub repositories and incorporating them into your primary project as Git submodules.

### Script Breakdown:

**1. Setup and Initialization:**

- `#!/bin/bash`: Specifies that the script should be executed using the Bash interpreter.
- `repos=()`: Declares an empty array named "repos". You need to populate this array with the actual URLs of your GitHub repositories containing documentation before running the script.
- `mkdir -p gitdocs`: Creates a directory named "gitdocs" if it doesn't already exist. This directory will serve as the central location for all cloned documentation.
- `cd gitdocs`: Changes the current working directory to "gitdocs".
- `git init`: Initializes an empty Git repository within the "gitdocs/" directory.

**2. Iterating through Repositories:**

The script uses a `for` loop to process each URL (repo) in the `repos` array:

- `repo_name=$(basename "$repo" .git)`: Extracts the repository name from the URL by removing the ".git" suffix using the `basename` command. For example, if `repo` is "https://github.com/username/repository.git", `repo_name` would be set to "repository".
- `git clone --no-checkout --depth 1 "$repo" submodules/$repo_name`: Clones the repository (without checking out any code) using shallow cloning (`--depth 1`) which fetches only the latest commit. The cloned repository is placed within a subdirectory named after the extracted repository name (`submodules/$repo_name`).

**3. Sparse Checkout:**

- `git sparse-checkout set docs Docs doc DOCS Doc DOC documents Documents README.md`: This line configures sparse checkout, instructing Git to only fetch specific files and directories related to documentation (e.g., "docs" folder, "README.md", etc.). Adjust this line if your repositories use a different documentation structure.

**4. Submodule Registration:**

After cloning all repositories, the script updates the project's `.gitmodules` file. This file tracks the submodules used in your main project.

**5. Submodule Synchronization:**

- `git submodule init`: Initializes all submodules listed in the `.gitmodules` file (creating directories for them if needed).
- `git submodule update`: Fetches and updates the contents of each submodule, pulling their latest code and making it accessible within your main project.

### Key Points:

- This script assumes a standard documentation folder structure ("docs" or similar). Adjust the `git sparse-checkout` lines accordingly if necessary.
- Remember to replace the `repos=() ` array with the actual URLs of your repository repos before running the script.

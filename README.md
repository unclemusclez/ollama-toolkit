# Ollama Toolkit

## Unleashing the Power of Ollama: Introducing the Ollama Toolkit 🚀🧰

[🔫 Water Pistol Discord](http://discord.waterpistol.co) | [🦙 Ollama Discord](https://discord.gg/ollama) | [🔍 Open WebUI Discord](https://discord.gg/5rJgQTnV4s)

The Ollama Toolkit is a collection of powerful tools designed to enhance your experience with the Ollama project, an open-source framework for deploying and scaling machine learning models. Think of it as your one-stop shop for streamlining workflows and unlocking the full potential of Ollama!

**General Purpose:**

The toolkit aims to simplify common tasks related to working with Ollama models and provide user-friendly interfaces for interacting with them. It empowers developers, researchers, and enthusiasts alike to:

- **Effortlessly Optimize Models:** Leverage scripts like "Ollamafy" to automate model quantization and conversion, making your models smaller, faster, and more efficient for deployment.
- **Centralize Documentation:** Utilize "DLGitDocs" to efficiently gather and organize documentation from various Ollama-related repositories, ensuring you have all the information you need at your fingertips.

**Current Tools:**

The toolkit currently includes:

- **Ollamafy:** This script automates the process of converting and optimizing Ollama models for different deployment scenarios.
- **DLGitDocs:** This script simplifies documentation management by cloning relevant repositories as Git submodules and selectively including only essential documentation files.

**Future Expansion:**

The Ollama Toolkit is constantly evolving, with plans to incorporate additional tools and features in the future. This may include:

- User-friendly graphical interfaces for interacting with Ollama models
- Tools for visualizing model performance and debugging issues
- Scripts for automating common tasks like model training and evaluation

By providing a comprehensive set of tools and resources, the Ollama Toolkit empowers users to harness the full power of Ollama and accelerate their machine learning workflows.

## Ollamafy 🦙✨

This Bash script is your AI model's personal trainer 💪! It takes your awesome models and gets them in tip-top shape for deployment with Ollama 🚀 by using quantization (think making them smaller and faster without losing too much accuracy).

**Here's the breakdown:**

- **Quantization Array:** Think of this as a menu 🍔 of different quantization levels. The script uses it to choose how "compressed" your model should be.

- **Argument Parsing:** This part listens carefully👂 to the commands you give it (username, model name, etc.) and stores them neatly for later use.

- **Input Validation:** The script is a stickler for details 🧐! It makes sure you've provided all the necessary information before moving forward.

- **Lowercasing Parameters:** No shouting allowed! 🗣️⬇️ The script converts everything to lowercase for consistency.

- **Latest Quantization Check:** If you want the very latest and greatest quantization, the script double-checks that it's available in the menu.

- **Quantization Loop:** This is where the magic happens ✨! The script goes through each quantization level:

  - **Tag Creation:** It creates a unique nameplate 🏷️ for your model (e.g., "johndoe/mymodel:q4_0").
  - **Version/Parameters Handling:** If you've specified a version or special parameters, it adds those to the nameplate too.

- **Model Creation:** Time to sculpt! 💪 The script uses `ollama create` to build your quantized model (or an FP16 version if you prefer).
- **Pushing Models:** Finally, the script sends your newly-minted model 🚀 to its destination using `ollama push`.

- **Latest Handling:** If you requested the latest quantization, the script updates the "latest" tag so everyone knows which version is the hottest 🔥!

## DLGitDocs: Streamlining Documentation Gathering 🚀📚

This Bash script is your trusty sidekick for effortlessly collecting documentation from multiple GitHub repositories! 🦸‍♂️

**Script Purpose:**

Imagine needing documentation from various projects scattered across GitHub. Manually downloading and organizing them can be a tedious chore 😩. DLGitDocs simplifies this process by automatically cloning these repositories as Git submodules and selectively including only the essential documentation files using sparse checkout.

**Functionalities:**

- **Cloning Repositories:** 🔁 The script zips through an array of repository URLs you provide and clones each one into a dedicated "submodules" directory within your main project (assumed to be named "gitdocs").

- **Sparse Checkout:** ✂️ To save space and processing time, DLGitDocs leverages Git's powerful sparse checkout feature. This allows it to cherry-pick only documentation-related directories (like "docs", "Docs", "doc") and files (such as README.md or any \*.md file) from each submodule.

- **.gitmodules Update:** 📝 The script automatically adds the configuration for these newly cloned submodules to your project's .gitmodules file, effectively registering them with your main Git repository.

- **Submodule Initialization:** 🌱 Finally, DLGitDocs initializes and updates all registered submodules, ensuring you have the latest documentation synchronized locally.

With DLGitDocs, gathering and organizing documentation becomes a breeze! 💨

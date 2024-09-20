# Ollamafy

## Ollamafy Script Documentation

This Bash script automates the process of building and pushing different quantized versions of a machine learning model using the ollama CLI.

### Usage:

```bash
./ollamafy.sh [options]
```

### Options:

- `-q|--quant [QUANTIZATION]`: Specify the quantization method to use (e.g., q4_0, fp16). Defaults to building all available quantizations.
- `-u|--username [USERNAME]`: Your username for the model registry.
- `-m|--model [MODEL_NAME]`: The name of your model.
- `v|--version [VERSION]`: (Optional) Version tag for the model.
- `-p|--parameters [PARAMETERS]`: (Optional) Parameters string for the model.
- `-l|--latest [LATEST]`: Specify a quantization to tag as "latest". Must be one of the available quantizations defined in the script.
- `-f|--file [MODEL_FILE]`: Path to your model file.

### Example:

```bash
./ollamafy.sh -u <mantainer_username> -m <modelname> -f </path/to/modelname.modelfile> -l q4_0 -v v1
```

### Script Breakdown:

- **Quantization Array:** Defines a list of supported quantizations (`QUANTIZATIONS`).
- **Argument Parsing:** Utilizes a while loop and case statement to parse command-line arguments, setting variables like `USERNAME`, `MODEL_NAME`, and `MODEL_FILE`.
- **Input Validation:** Checks if required flags (`--username`, `--model`, `--file`) are provided.
- **String Normalization:** Converts usernames, model names, versions, and parameters to lowercase for consistency.
- **Latest Quantization Check:** If `LATEST` is specified, verifies that it's present in the `QUANTIZATIONS` array.
- **Quantization Loop:**
  - Iterates through each quantization method `QUANT` in the `QUANTIZATIONS` array (or a single quantization if the `QUANTIZATION` flag is used).
  - Constructs the model tag using the following pattern:
    - `"$USERNAME/$MODEL_NAME:$QUANT"` (base tag)
  - Then appends additional modifiers based on provided arguments:
    - Parameters and Version:
      `"$USERNAME/$MODEL_NAME:$PARAMETERS-$VERSION-$QUANT"` (with parameters and version)
  - Uses the ollama create command:
    - For FP16 quantization (`QUANT = "fp16"`): simply creates the model.
    - For other quantizations: uses the `--quantize $QUANT` flag for quantization during model creation.
  - Pushing to Hub: Pushes the created model to the model registry using ollama push.
- **Latest Tagging (if applicable):**
  - If `LATEST` is set, copies the current quantized model to `"$USERNAME/$MODEL_NAME:latest"` and pushes it.
  - Also copies and pushes the model with specified version if available.

### Assumptions:

- You have ollama CLI installed and configured.
- The `MODEL_FILE` exists at the provided path.

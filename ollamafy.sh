#!/bin/bash
echo "Script started"
OLLAMAFY_QUANTIZATIONS=(
    "fp16"
    "q2_K"
    "q3_K_S"
    "q3_K_M"
    "q3_K_L"
    "q4_0"
    "q4_1"
    "q4_K_S"
    "q4_K_M"
    "q5_0"
    "q5_1"
    "q5_K_S"
    "q5_K_M"
    "q6_K"
    "q8_0"
    # "iq1_s"
    "iq2_s"
    # "iq2_xs"
    # "iq2_xxs"
    "iq3_s"
    # "iq3_xxs"
    # "iq4_xs"
    "iq4_nl"
)
# OLLAMAFY_FORCE_WRITE=false
OLLAMAFY_FORCE_PUSH=false
OLLAMAFY_TEST=false
OLLAMAFY_LOCAL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quant) OLLAMAFY_QUANTIZATION="$2"; shift 2 ;;
        -u|--username) OLLAMAFY_USERNAME="$2"; shift 2 ;;
        -m|--model) OLLAMAFY_MODEL_NAME="$2"; shift 2 ;;
        -v|--version) OLLAMAFY_VERSION="$2"; shift 2 ;;
        -p|--parameters) OLLAMAFY_PARAMETERS="$2"; shift 2 ;;
        -l|--latest) OLLAMAFY_LATEST="$2"; shift 2 ;;
        -f|--file) OLLAMAFY_MODEL_FILE="$2"; shift 2 ;;
        -fw|--force-write) OLLAMAFY_FORCE_WRITE=true shift ;;
        -fp|--force-push) OLLAMAFY_FORCE_PUSH=true; shift ;;
        -tr|--test-run) OLLAMAFY_TEST=true; shift ;;
        -lo|--local) OLLAMAFY_LOCAL=true; shift ;;
        *) echo "Unknown flag: $1"; exit 1 ;;
    esac
done

if [ -z "$OLLAMAFY_USERNAME" ] || [ -z "$OLLAMAFY_MODEL_NAME" ] || [ -z "$OLLAMAFY_MODEL_FILE" ]; then
    echo "Error: --username, --model, and --file are required"
    exit 1
fi

OLLAMAFY_USERNAME=$(echo "$OLLAMAFY_USERNAME" | tr '[:upper:]' '[:lower:]')
OLLAMAFY_MODEL_NAME=$(echo "$OLLAMAFY_MODEL_NAME" | tr '[:upper:]' '[:lower:]')
OLLAMAFY_VERSION=$(echo "$OLLAMAFY_VERSION" | tr '[:upper:]' '[:lower:]')
OLLAMAFY_PARAMETERS=$(echo "$OLLAMAFY_PARAMETERS" | tr '[:upper:]' '[:lower:]')
OLLAMAFY_LATEST=$(echo "$OLLAMAFY_LATEST" | tr '[:upper:]' '[:lower:]')

if [ -n "$OLLAMAFY_LATEST" ] || [[ ! " ${OLLAMAFY_QUANTIZATIONS[*]} " =~  $OLLAMAFY_LATEST ]]; then
    echo "Error: LATEST must be one of the available quantizations"
    exit 1
fi

if [ -n "$OLLAMAFY_QUANTIZATION" ] && [[ " ${OLLAMAFY_QUANTIZATIONS[*]} " =~ $OLLAMAFY_QUANTIZATION ]]; then
    OLLAMAFY_QUANTIZATIONS=("$OLLAMAFY_QUANTIZATION")
fi

echo "Going through Quants."
OLLAMAFY_MODEL_NAME_BASE="$OLLAMAFY_USERNAME/$OLLAMAFY_MODEL_NAME"



for OLLAMAFY_MODEL_QUANTIZATION in "${OLLAMAFY_QUANTIZATIONS[@]}"; do
    MODEL_TAG="$OLLAMAFY_MODEL_NAME_BASE"
    echo "Current model is: $MODEL_TAG"
    # Start with username and model name
    if [ "$OLLAMAFY_VERSION" ] && [ "$OLLAMAFY_PARAMETERS" ]; then
        MODEL_TAG="$MODEL_TAG:$OLLAMAFY_PARAMETERS-$OLLAMAFY_VERSION-$OLLAMAFY_MODEL_QUANTIZATION"
    else
        [ ! "$OLLAMAFY_VERSION" ] && MODEL_TAG="$MODEL_TAG:$OLLAMAFY_PARAMETERS-$OLLAMAFY_MODEL_QUANTIZATION"
        [ ! "$OLLAMAFY_PARAMETERS" ] && MODEL_TAG="$MODEL_TAG:$OLLAMAFY_VERSION-$OLLAMAFY_MODEL_QUANTIZATION"
    fi
    echo "TESTRUN = $OLLAMAFY_TEST for $MODEL_TAG"
    if [ "$OLLAMAFY_TEST" = true ]; then
        [ "$OLLAMAFY_LATEST" = "$OLLAMAFY_MODEL_QUANTIZATION" ] && echo "$OLLAMAFY_MODEL_NAME_BASE:latest"
        [ "$OLLAMAFY_PARAMETERS" ] && echo "$OLLAMAFY_MODEL_NAME_BASE:$OLLAMAFY_PARAMETERS"
        
    else
        if [[ "$OLLAMAFY_TEST" = false ]]; then
            if ollama list | grep "$MODEL_TAG"; then
                echo "$MODEL_TAG found. Skipping."
                if [ $OLLAMAFY_FORCE_PUSH = true ]; then
                    echo "Force-Push is Active."
                    ollama push "$MODEL_TAG"
                    if [ "$OLLAMAFY_LATEST" = "$OLLAMAFY_MODEL_QUANTIZATION" ]; then
                        ollama cp "$MODEL_TAG" "$OLLAMAFY_MODEL_NAME_BASE:latest"
                        if [ "$OLLAMAFY_LOCAL" = false ]; then
                            ollama push "$OLLAMAFY_MODEL_NAME_BASE:latest"
                            if [ "$OLLAMAFY_PARAMETERS" ]; then
                                ollama cp "$MODEL_TAG" "$OLLAMAFY_MODEL_NAME_BASE:$OLLAMAFY_PARAMETERS"
                                [ "$OLLAMAFY_LOCAL" = false ] && ollama push "$OLLAMAFY_MODEL_NAME_BASE:$OLLAMAFY_PARAMETERS"
                            fi
                        fi
                    fi
                fi
            else
                if [ "$OLLAMAFY_MODEL_QUANTIZATION" = "fp16" ]; then
                    ollama create -f "$OLLAMAFY_MODEL_FILE" "$MODEL_TAG"
                else
                    ollama create --quantize "$OLLAMAFY_MODEL_QUANTIZATION" -f "$OLLAMAFY_MODEL_FILE" "$MODEL_TAG"
                fi
                
                [ "$OLLAMAFY_LOCAL" = false ] && ollama push "$MODEL_TAG"
                
                if [ "$OLLAMAFY_LATEST" = "$OLLAMAFY_MODEL_QUANTIZATION" ]; then
                    ollama cp "$MODEL_TAG" "$OLLAMAFY_MODEL_NAME_BASE:latest"
                    if [ "$OLLAMAFY_LOCAL" = false ]; then
                        ollama push "$OLLAMAFY_MODEL_NAME_BASE:latest"
                        if [ "$OLLAMAFY_PARAMETERS" ]; then
                            ollama cp "$MODEL_TAG" "$OLLAMAFY_MODEL_NAME_BASE:$OLLAMAFY_PARAMETERS"
                            [ "$OLLAMAFY_LOCAL" = false ] && ollama push "$OLLAMAFY_MODEL_NAME_BASE:$OLLAMAFY_PARAMETERS"
                        fi
                    fi
                fi
            fi
        fi
    fi
done
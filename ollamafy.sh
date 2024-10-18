#!/bin/bash
echo "Script started"
QUANTIZATIONS=(
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
  "iq1_s"
  "iq2_s"
  "iq2_xs"
  "iq2_xxs"
  "iq3_s"
  "iq3_xxs"
  "iq4_xs"
  "iq4_nl"
)

while [[ $# -gt 0 ]]; do
  case $1 in
    -q|--quant) QUANTIZATION="$2"; shift 2 ;;
    -u|--username) USERNAME="$2"; shift 2 ;;
    -m|--model) MODEL_NAME="$2"; shift 2 ;;
    -v|--version) VERSION="$2"; shift 2 ;;
    -p|--parameters) PARAMETERS="$2"; shift 2 ;;
    -l|--latest) LATEST="$2"; shift 2 ;;
    -f|--file) MODEL_FILE="$2"; shift 2 ;;
    -w|--force-write) FORCE_WRITE=True shift ;;
    -x|--force-push) FORCE_PUSH=True; shift ;;
    -t|--test) TEST=True; shift ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

if [ -z "$USERNAME" ] || [ -z "$MODEL_NAME" ] || [ -z "$MODEL_FILE" ]; then
  echo "Error: --username, --model, and --file are required"
  exit 1
fi

USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]')
MODEL_NAME=$(echo "$MODEL_NAME" | tr '[:upper:]' '[:lower:]')
VERSION=$(echo "$VERSION" | tr '[:upper:]' '[:lower:]')
PARAMETERS=$(echo "$PARAMETERS" | tr '[:upper:]' '[:lower:]')
LATEST=$(echo "$LATEST" | tr '[:upper:]' '[:lower:]')
FORCE_WRITE=False
FORCE_PUSH=False
TEST=False

if [ -n "$LATEST" ] && [[ ! " ${QUANTIZATIONS[@]} " =~ " $LATEST " ]]; then
  echo "Error: LATEST must be one of the available quantizations"
  exit 1
fi

if [ -n "$QUANTIZATION" ]; then
  QUANTIZATIONS=("$QUANTIZATION")
fi
echo "Going through Quants."
for QUANT in "${QUANTIZATIONS[@]}"; do
  echo "Current model is: $USERNAME/$MODEL_NAME:$QUANT"
  [ -n "$PARAMETERS" ] && MODEL_TAG="$USERNAME/$MODEL_NAME:$PARAMETERS-$QUANT"
  [ -n "$VERSION" ] && MODEL_TAG="$USERNAME/$MODEL_NAME:$VERSION-$QUANT"
  [ -n "$PARAMETERS" ] && [ -n "$VERSION" ] && MODEL_TAG="$USERNAME/$MODEL_NAME:$PARAMETERS-$VERSION-$QUANT"

  if [ "$FORCE_WRITE" = "0" ]; then
    echo "FORCE_WRITE = $FORCE_WRITE"
    if ollama list | grep -q "$MODEL_TAG"; then
      echo "$MODEL_TAG found. Skipping Quantization."
      if [ "$FORCE_PUSH" = "1" ]; then
        ollama push "$MODEL_TAG"
      fi
    fi
  else
    if [ "$TEST" = "True" ]; then
      echo 'TEST MODE = $TEST $MODEL_TAG'
      [ "$LATEST" = "$QUANT" ] && echo "$USERNAME/$MODEL_NAME:latest"
      [ -n "$PARAMETERS" ] && echo "$USERNAME/$MODEL_NAME:$PARAMETERS"
    else
      if [ "$QUANT" = "fp16" ]; then
        ollama create -f "$MODEL_FILE" "$MODEL_TAG"
      else
        ollama create --quantize "$QUANT" -f "$MODEL_FILE" "$MODEL_TAG"
      fi

      ollama push "$MODEL_TAG"

      if [ "$LATEST" = "$QUANT" ]; then
        ollama cp "$MODEL_TAG" "$USERNAME/$MODEL_NAME:latest"
        ollama push "$USERNAME/$MODEL_NAME:latest"
      fi

      if [ -n "$PARAMETERS" ]; then
        ollama cp "$MODEL_TAG" "$USERNAME/$MODEL_NAME:$PARAMETERS"
        ollama push "$USERNAME/$MODEL_NAME:$PARAMETERS"
      fi
    fi
  fi
done
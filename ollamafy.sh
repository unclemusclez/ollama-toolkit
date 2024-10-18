#!/bin/bash
QUANTIZATIONS=(
 "q4_0"
 "q4_1"
 "q5_0"
 "q5_1"
 "q8_0"
 "q3_K_S"
 "q3_K_M"
 "q3_K_L"
 "q4_K_S"
 "q4_K_M"
 "q5_K_S"
 "q5_K_M"
 "q6_K"
 "q2_K"
 "fp16"
)
FORCE_WRITE=True
FORCE_PUSH=False

while [[ $# -gt 0 ]]; do
 case $1 in
  -q|--quant) QUANTIZATION="$2"; shift 2 ;;
  -u|--username) USERNAME="$2"; shift 2 ;;
  -m|--model) MODEL_NAME="$2"; shift 2 ;;
  -v|--version) VERSION="$2"; shift 2 ;;
  -p|--parameters) PARAMETERS="$2"; shift 2 ;;
  -l|--latest) LATEST="$2"; shift 2 ;;
  -f|--file) MODEL_FILE="$2"; shift 2 ;;
  -w|--force-write) FORCE_WRITE=True; shift 2 ;;
  -u|--force-push) FORCE_PUSH=True; shift 2 ;;
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

if [ -n "$LATEST" ] && [[ ! " ${QUANTIZATIONS[@]} " =~ " $LATEST " ]]; then
 echo "Error: LATEST must be one of the available quantizations"
 exit 1
fi

if [ -n "$QUANTIZATION" ]; then
 QUANTIZATIONS=("$QUANTIZATION")
fi

for QUANT in "${QUANTIZATIONS[@]}"; do
  MODEL_TAG="$USERNAME/$MODEL_NAME:$QUANT" 
    if [ -n "$PARAMETERS" ]; then 
      MODEL_TAG="$USERNAME/$MODEL_NAME:$PARAMETERS-$QUANT"
    fi  
    if [ -n "$VERSION" ]; then
      MODEL_TAG="$USERNAME/$MODEL_NAME:$VERSION-$QUANT"
    fi
    if [ -n "$PARAMETERS" -a -n "$VERSION" ]; then 
      MODEL_TAG="$USERNAME/$MODEL_NAME:$PARAMETERS-$VERSION-$QUANT"
    fi
if FORCE_WRITE=False; then
  if ollama list | grep $MODEL_TAG; then
    echo "$MODEL_TAG found. Skipping Quantization."
    if FORCE_PUSH=True; then;
      ollama push "$MODEL_TAG"
    fi
  fi
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

  [ -n "$PARAMETERS" ] && ( ollama cp "$MODEL_TAG" "$USERNAME/$MODEL_NAME:$PARAMETERS"; ollama push "$USERNAME/$MODEL_NAME:$PARAMETERS" )
fi
done
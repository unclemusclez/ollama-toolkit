@setlocal enableDelayedExpansion

set QUANTIZATIONS=(
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

set QUANTIZATION=
set USERNAME=
set MODEL_NAME=
set VERSION=
set PARAMETERS=
set LATEST=
set MODEL_FILE=

:parseArgsLoop

if "%1" eq "" goto endParseArgs

if "%1"== "-q" || "%1"== "--quant" (
  set QUANTIZATION=%2
  shift /1
)

if "%1"== "-u" || "%1"== "--username" (
  set USERNAME=%2
  shift /1
)

if "%1"== "-m" || "%1"== "--model" (
  set MODEL_NAME=%2
  shift /1
)

if "%1"== "-v" || "%1"== "--version" (
  set VERSION=%2
  shift /1
)

if "%1"== "-p" || "%1"== "--parameters" (
  set PARAMETERS=%2
  shift /1
)

if "%1"== "-l" || "%1"== "--latest" (
  set LATEST=%2
  shift /1
)

if "%1"== "-f" || "%1"== "--file" (
  set MODEL_FILE=%2
  shift /1
)

echo "Unknown flag: !1!"&goto endParseArgs

:shift

shift /1

goto parseArgsLoop
:endParseArgs



IF "!USERNAME!" == "" OR "!MODEL_NAME!" == "" OR "!MODEL_FILE!" == "" (
    echo error: --username, --model, and --file are required
     exit /b 1
)


set USERNAME=!USERNAME:%=g!

set MODEL_NAME=!MODEL_NAME:%=g!
set VERSION=!VERSION:%=g!

set PARAMETERS=!PARAMETERS:%=g!

set LATEST=!LATEST:%=g!



if not "!LATEST!" == "" (
  for %%Q in (%QUANTIZATIONS%) do (
    IF "!LATEST!" == "%%Q" GOTO latestFound
  )


  ECHO error: LATEST must be one of the available quantizations.
  EXIT 1

:latestfound
 )



if not "!QUANTIZATION!".== "" (
   set QUANTIZATIONS=(!QUANTIZATION!)

)





for %%Q in (%QUANTIZATIONS%) do (

 set MODEL_TAG=!USERNAME!/%MODEL_NAME!:%%Q

 if not "!PARAMETERS!" == "" set MODEL_TAG=!USERNAME!/%MODEL_NAME!:%PARAMETERS%-%%Q

 if not "!VERSION!" == "" set MODEL_TAG=!USERNAME!/%MODEL_NAME!:%VERSION%-%%Q

 if "!PARAMETERS!" neq "" AND "!VERSION!" neq "" (
   set MODEL_TAG=!USERNAME!/%MODEL_NAME!:%PARAMETERS%-%VERSION%-%%Q
  )

 IF "%%Q" == "fp16" ollama create -f "%MODEL_FILE%" %MODEL_TAG%
 IF NOT "%%Q" == "fp16" (
   ollama create --quantize "%%Q" -f "%MODEL_FILE%" %MODEL_TAG% )

 ollama push %MODEL_TAG%

  if "!LATEST!"== "%%Q" (
    ollama cp %MODEL_TAG% !USERNAME!/%MODEL_NAME%:latest

    ollama push !USERNAME!/%MODEL_NAME%:latest


 IF not "!VERSION!" == "" olama cp %MODEL_TAG% !USERNAME!/!MODEL_NAME!:%VERSION%! 

    IF not "!VERSION!" == "" olaam push !USERNAME!/!MODEL_NAME!:%VERSION%! )
)

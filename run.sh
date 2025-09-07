run_id=$1
instance=$2
dataset=$3
use_apptainer=true
runs=25

# cpp examples
model='google/gemma-2-9b-it'
bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${model//\//_}" "$model" 'openrouter' 'codearena_local' 'cpp' "$dataset" "$use_apptainer"
model='meta-llama/llama-3-8b-instruct'
bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${model//\//_}" "$model" 'openrouter' 'codearena_local' 'cpp' "$dataset" "$use_apptainer"
model='qwen/qwen-2.5-coder-32b-instruct'
bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${model//\//_}" "$model" 'openrouter' 'codearena_local' 'cpp' "$dataset" "$use_apptainer"

# java examples
# model='google/gemma-2-9b-it'
# bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${model//\//_}" "$model" 'openrouter' 'codearena_local' 'java' "$dataset" "$use_apptainer"
# model='meta-llama/llama-3-8b-instruct'
# bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${model//\//_}" "$model" 'openrouter' 'codearena_local' 'java' "$dataset" "$use_apptainer"
# model='qwen/qwen-2.5-coder-32b-instruct'
# bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${model//\//_}" "$model" 'openrouter' 'codearena_local' 'java' "$dataset" "$use_apptainer"
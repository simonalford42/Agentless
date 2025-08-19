run_id=$1
instance=$2
dataset=$3
use_apptainer=false
runs=30

# model='gemma2-9b-it'
# bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${instance}_${model}" "$model" 'groq' 'codearena_local' 'java' "$dataset" "$use_apptainer"
model='llama3-8b-8192'
bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_${instance}_${model}" "$model" 'groq' 'codearena_local' 'java' "$dataset" "$use_apptainer"
# model='google/gemma-2-9b-it'
# bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_1" "$model" 'openrouter' 'codearena_local' 'java' "$dataset" "$use_apptainer"
# model2='meta-llama/llama-3-8b-instruct'
# bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_2" "$model2" 'openrouter' 'codearena_local' 'java' "$dataset" "$use_apptainer"
# model3='qwen/qwen-2.5-coder-32b-instruct'
# bash full_bad_patch_gen.sh "$instance" "$runs" "${run_id}_3" "$model3" 'openrouter' 'codearena_local' 'java' "$dataset" "$use_apptainer"

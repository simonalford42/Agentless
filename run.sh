run_id=$1
instance=$2
dataset=$3
model=$4
runs=25

# model='gemma2-9b-it'
# bash full_bad_patch_gen.sh $instance $runs "${run_id}_4" $model 'groq' 'codearena_local' 'java' $dataset

model='google/gemma-2-9b-it'
bash full_bad_patch_gen.sh $instance $runs "${run_id}_12" $model 'openrouter' 'codearena_local' 'java' $dataset
model2='meta-llama/llama-3-8b-instruct'
bash full_bad_patch_gen.sh $instance $runs "${run_id}_13" $model2 'openrouter' 'codearena_local' 'java' $dataset
model3='qwen/qwen-2.5-coder-32b-instruct'
bash full_bad_patch_gen.sh $instance $runs "${run_id}_14" $model3 'openrouter' 'codearena_local' 'java' $dataset

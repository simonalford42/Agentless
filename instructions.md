# Setup

1. Clone the Agentless repo (into `codearena/baselines/`) and create a conda environment for it:

```bash
git clone https://github.com/simonalford42/Agentless.git
cd Agentless
# conda create -n agentless python=3.11
# conda activate agentless
pip install -r requirements.txt
```

or setup using gitmodules.

2. Make sure you have an LLM API key set and that Docker is working

# Running Agentless

`run.sh` runs the agentless bad patch generation with options that you can set. It will call `full_bad_patch_gen.sh` and run 1 file localization method for function localization. `run.sh` is essentially a scrath file for adding the patches you want to generate for. It taks 3 arguments: run_id, instance, and dataset. Some examples:

```bash
# Get Parameters.
run_id=$1
instance=$2
dataset=$3
# Default value
runs=25

model='google/gemma-2-9b-it'
bash full_bad_patch_gen.sh $instance $runs "${run_id}_12" $model 'openrouter' 'codearena_local' 'java' $dataset

model2='meta-llama/llama-3-8b-instruct'
bash full_bad_patch_gen.sh $instance $runs "${run_id}_13" $model2 'openrouter' 'codearena_local' 'java' $dataset

model3='qwen/qwen-2.5-coder-32b-instruct'
bash full_bad_patch_gen.sh $instance $runs "${run_id}_14" $model3 'openrouter' 'codearena_local' 'java' $dataset
```

`full_bad_patch_gen.sh` has several default parameters:

```bash
RUN_ID=${3:-'default_run_id'}
MODEL=${4:-'gemini-1.5-flash'}
BACKEND=${5:-'google'}
DATASET=${6:-'codearena_local'}
LANGUAGE=${7:-'python'}
DATAFILE=${8:-'data/multiswebench_data/mswebench_instances_copy.json'}
```

`full_bad_patch_gen.sh` runs the agentless bad patch generation. It uses 3 different file localization methods, and stops once a bad patch is successfully created

`bad_patch_gen.sh` runs the agentless bad patch generation for a specific file localization method. It will also run `codearena.py` on the results it gets from agentless, and it will run `bad_patch_validation.py` after that. This will process the bad patches into their own individual json files to be process back into the dataset later. This allows for parallelism.

The scripts were derived from the instructions and commands at https://github.com/simonalford42/Agentless/blob/main/README_swebench.md. See that page for full explanation and instructions.
Note: It will ask you to trust custom code. This is to load the codearena instances into a local huggingface dataset (`codearena_local.py`) to interface with Agentless.

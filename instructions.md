# Setup
1. Clone the Agentless repo (into `codearena/baselines/`) and create a conda environment for it:

```bash
git clone https://github.com/simonalford42/Agentless.git
cd Agentless
conda create -n agentless python=3.11
conda activate agentless
pip install -r requirements.txt
```

2. Make sure you have an LLM API key set and that Docker is working

# Running Agentless
`full_bad_patch_gen.sh` runs the agentless bad patch generation. It uses 3 different file localization methods, and stops once a bad patch is successfully created
`bad_patch_gen.sh` runs the agentless bad patch generation for a specific file localization method.

The scripts were derived from the instructions and commands at https://github.com/simonalford42/Agentless/blob/main/README_swebench.md. See that page for full explanation and instructions.
Note: It will ask you to trust custom code. This is to load the codearena instances into a local huggingface dataset (`codearena_local.py`) to interface with Agentless.

# Setup
1. Clone the Agentless repo (into `codearena/baselines/`) and create a conda environment for it:

```bash
git clone https://github.com/simonalford42/Agentless.git
cd Agentless
conda create -n agentless python=3.11
conda activate agentless
pip install -r requirements.txt
```

2. Make sure you have an OpenAI API key set to the `OPENAI_API_KEY` environment variable and that Docker is working.

# Running Agentless
1. At the beginning of `run_agentless.sh`, set the `TARGET_ID` variable (can also optionally change `SAMPLES` and `OUTPUT_DIR`).
2. `bash run_agentless.sh` will run the method via a sequence of python commands for the different steps. The script was derived from the instructions and commands at https://github.com/simonalford42/Agentless/blob/main/README_swebench.md, see that page for full explanation and instructions.
    Note: It will ask you to trust custom code. This is to load the codearena instances into a local huggingface dataset (`codearena_local.py`) to interface with Agentless.
3. `python clean_sweagent_outputs.py /baselines/Agentless/results/$OUTPUT_DIR/all_preds.jsonl`
4. `python codearena.py --BugFixing --predictions_path baselines/Agentless/results/$OUTPUT_DIR/all_preds.jsonl --instance_ids $TARGET_ID --run_id test`



Notes:
- I removed the reproduction tests so that it doesn't reject patches. Without doing this, the agent would usually not be able to come up with anything, or (once) what it came up with solved the issue, which isn't what we want.
- This uses OpenAI credits, but if you use 4o mini and 1 sample it isn't very expensive. For me it takes ~5-10 minutes and 10 cents to get one sample for a task. You can track usage at https://platform.openai.com/settings/organization/usage.

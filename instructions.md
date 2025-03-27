# Instructions
1. Clone repo (into `codearena/baselines/`), create environment:

```bash
git clone https://github.com/simonalford42/Agentless/tree/main.git
cd Agentless
conda create -n agentless python=3.11
conda activate agentless
pip install -r requirements.txt
```

2. Make sure openai api key and docker envs are setup.
3. Set up target id, samples, output dir.
4. `bash run_agentless.sh` will run the method via a sequence of python commands for the different steps. See https://github.com/simonalford42/Agentless/blob/main/README_swebench.md for full instructions.

    Note: It will ask you to trust custom code. This is to load the codearena instances into a local huggingface dataset (`codearena_local.py`) to interface with Agentless.


Notes:
- I removed the reproduction tests so that it doesn't reject patches. Without doing this, the agent would usually not be able to come up with anything, or (once) what it came up with solved the issue, which isn't what we want.
- This uses OpenAI credits, but if you use 4o mini and 1 sample it isn't very expensive. For me it takes ~10 minutes and 10 cents per task.

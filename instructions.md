# Instructions
1. follow instructions here to setup repo, environment: https://github.com/OpenAutoCoder/Agentless/blob/main/README_swebench.md
2. the installation newest version of swebench by default. make sure older version is installed:
`pip install git+https://github.com/swe-bench/SWE-bench@e0b9bf9#egg=swebench`
3. the script is set up to run on swe-bench datasets. in order to make it work on our data, you need to go through different files and remove the "choices" required to choose from for the dataset arg. For example, in

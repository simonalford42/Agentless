#%% Setup
INSTANCE_ID=$1
SAMPLES=$2
RUN_ID=$3
OUTPUT_DIR=${INSTANCE_ID}_n${SAMPLES}_$RUN_ID
MODEL='gpt-4.1-nano'

# add cd to path
export PYTHONPATH=$PYTHONPATH:$(pwd)
# do the same for codearena repo so we can access monkeypatched swebench
cd ../../
export PYTHONPATH=$PYTHONPATH:$(pwd)
cd baselines/Agentless

# make sure OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY is not set"
    exit 1
fi

#%% Check each of the generated patches to see if any are bad
cd ../../
for i in {1..4}; do
    folder=baselines/Agentless/results/$OUTPUT_DIR/repair_sample_$i
    for ((num=0; num<$SAMPLES; num++)); do
        # check for empty patch; skip if empty
        file="${folder}/output_${num}_processed.jsonl"

        if ! grep -q '"model_patch"[[:space:]]*:[[:space:]]*""' "$file"; then
            run_id="check_bad_patch_${OUTPUT_DIR}_${i}_${num}"

            # if it's a bad patch, add it to the dataset. returns 0 if bad and added, or 1 otherwise
            python bad_patch_validation.py --results_folder $run_id \
                                           --instance_id $INSTANCE_ID
            # once bad patch found, stop testing the samples
            if [ $? -eq 0 ]; then
                exit 0
            fi
        fi
    done
done

# no bad patch found, exit 1
exit 1

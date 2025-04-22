#%% Setup
INSTANCE_ID=$1
SAMPLES=$2
RUN_ID=$3

OUTPUT_DIR=${INSTANCE_ID}_n${SAMPLES}_$RUN_ID
# MODEL="gpt-4o-mini-2024-07-18"
MODEL='gpt-4.1-nano'
# MODEL='gpt-4.1-mini'

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

#%% Localization via gold patch
# python agentless/fl/gold_localize.py --target_id $INSTANCE_ID \
#                                      --output_folder results/$OUTPUT_DIR/edit_location_individual \
#                                      --output_file loc_outputs.jsonl \
#                                      --include_locs \
#                                      --dataset codearena_local
# echo "Localization done"

# python agentless/repair/repair.py --loc_file results/$OUTPUT_DIR/edit_location_individual/loc_outputs.jsonl \
#                                 --output_folder results/$OUTPUT_DIR/repair_sample \
#                                 --loc_interval \
#                                 --top_n=3 \
#                                 --context_window=10 \
#                                 --max_samples $SAMPLES \
#                                 --cot \
#                                 --diff_format \
#                                 --gen_and_process \
#                                 --num_threads 2 \
#                                 --target_id $INSTANCE_ID \
#                                 --model $MODEL \
#                                 --dataset codearena_local
# echo "Repair done"

#%% Check each of the generated patches to see if any are bad
cd ../../
folder=baselines/Agentless/results/$OUTPUT_DIR/repair_sample
for ((num=0; num<$SAMPLES; num++)); do
    run_id="check_bad_patch_${OUTPUT_DIR}_${num}"
    # run tests to see if it's a bad patch
    # python codearena.py --BugFixing --predictions_path="${folder}/output_${num}_processed.jsonl" \
                        # --instance_ids $INSTANCE_ID \
                        # --run_id=$run_id

    # if it's a bad patch, add it to the dataset. returns 0 if bad and added, or 1 otherwise
    python bad_patch_validation.py --results_folder $run_id --instance_id $INSTANCE_ID
    # once bad patch found, stop testing the samples
    if [ $? -eq 0 ]; then
        exit 0
    fi
done

#%% Setup
INSTANCE_ID=$1
# if second arg passed, set it to SAMPLES, otherwise use 1 sample
if [ -z "$2" ]; then
    SAMPLES=1
else
    SAMPLES=$2
fi
OUTPUT_DIR=${INSTANCE_ID}_n${SAMPLES}
# MODEL="gpt-4o-mini-2024-07-18"
MODEL='gpt-4.1-nano'

# add cd to path
export PYTHONPATH=$PYTHONPATH:$(pwd)
# do the same for codearena repo so we can access monkeypatched swebench
cd ../../
export PYTHONPATH=$PYTHONPATH:$(pwd)
cd baselines/Agentless

# exit immediately if any of the commands fail
set -e

# make sure OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY is not set"
    exit 1
fi

#%% Localization via gold patch
python agentless/fl/gold_localize.py --target_id $INSTANCE_ID \
                                     --output_folder results/$OUTPUT_DIR/file_level_combined \
                                     --output_file combined_locs.jsonl \
                                     --dataset codearena_local
echo "Finished acquiring gold patch file level localization"

#%% Related elements localization
python agentless/fl/localize.py --related_level \
                                --output_folder results/$OUTPUT_DIR/related_elements \
                                --top_n 3 \
                                --compress_assign \
                                --compress \
                                --start_file results/$OUTPUT_DIR/file_level_combined/combined_locs.jsonl \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id $INSTANCE_ID \
                                --model $MODEL \
                                --dataset codearena_local
echo "Finished running related elements localization"

#%% Fine-grained line-level localization
python agentless/fl/localize.py --fine_grain_line_level \
                                --output_folder results/$OUTPUT_DIR/edit_location_samples \
                                --top_n 3 \
                                --compress \
                                --temperature 0.8 \
                                --num_samples 4 \
                                --start_file results/$OUTPUT_DIR/related_elements/loc_outputs.jsonl \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id $INSTANCE_ID \
                                --model $MODEL \
                                --dataset codearena_local
echo "Finished running fine-grained line-level localization"

#%% Merge edit locations
python agentless/fl/localize.py --merge \
                                --output_folder results/$OUTPUT_DIR/edit_location_individual \
                                --top_n 3 \
                                --num_samples 4 \
                                --start_file results/$OUTPUT_DIR/edit_location_samples/loc_outputs.jsonl \
                                --target_id $INSTANCE_ID \
                                --model $MODEL \
                                --dataset codearena_local
echo "Finished running edit locations merge"

# #%% Localization via gold patch
# python agentless/fl/gold_localize.py --target_id $INSTANCE_ID \
#                                      --output_folder results/$OUTPUT_DIR/edit_location_invidual \
#                                      --include_locs \
#                                      --dataset codearena_local

# echo "Finished acquiring gold patch file level localization"

# #%% Repair for each set of edit locations
for i in {0..3}; do
    python agentless/repair/repair.py --loc_file results/$OUTPUT_DIR/edit_location_individual/loc_merged_${i}-${i}_outputs.jsonl \
                                    --output_folder results/$OUTPUT_DIR/repair_sample_$((i+1)) \
                                    --loc_interval \
                                    --top_n=3 \
                                    --context_window=10 \
                                    --max_samples $SAMPLES \
                                    --cot \
                                    --diff_format \
                                    --gen_and_process \
                                    --num_threads 2 \
                                    --target_id $INSTANCE_ID \
                                    --model $MODEL \
                                    --dataset codearena_local
done
echo "Finished running repair for all edit locations"

#%% Check each of the generated patches to see if any are bad
cd ../../
for i in {1..4}; do
    folder=baselines/Agentless/results/$OUTPUT_DIR/repair_sample_$i
    for ((num=0; num<$SAMPLES; num++)); do
        run_id="check_bad_patch_${OUTPUT_DIR}_${i}_${num}"
        # run tests to see if it's a bad patch
        # python codearena.py --BugFixing --predictions_path="${folder}/output_${num}_processed.jsonl" \
        #                     --instance_ids $INSTANCE_ID \
        #                     --run_id=$run_id
        # if it's a bad patch, add it to the dataset. returns 0 if bad and added, or 1 otherwise
        python bad_patch_validation.py --results_folder $run_id --instance_id $INSTANCE_ID
        # once bad patch found, stop testing the samples
        if [ $? -eq 0 ]; then
            exit 0
        fi
    done
done

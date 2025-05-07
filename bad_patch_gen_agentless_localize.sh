#%% Setup
INSTANCE_ID=$1
SAMPLES=$2
RUN_ID=$3
OUTPUT_DIR=${INSTANCE_ID}_n${SAMPLES}_$RUN_ID

# MODEL='gpt-4.1-nano'
# BACKEND='openai'
# MODEL='gemini-2.5-flash-preview-04-17'
MODEL='gemini-2.0-flash-lite'
BACKEND='google'
DATASET='codearena_local'

# add cd to path
export PYTHONPATH=$PYTHONPATH:$(pwd)
# do the same for codearena repo so we can access monkeypatched swebench
cd ../../
export PYTHONPATH=$PYTHONPATH:$(pwd)
cd baselines/Agentless

set -e

#%% File-level localization
python agentless/fl/localize.py --file_level \
                                --output_folder results/$OUTPUT_DIR/file_level \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id $INSTANCE_ID \
                                --model $MODEL \
                                --backend $BACKEND \
                                --dataset $DATASET
echo "Finished running file-level localization"

#%% Irrelevant file filtering
python agentless/fl/localize.py --file_level \
                                --irrelevant \
                                --output_folder results/$OUTPUT_DIR/file_level_irrelevant \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id $INSTANCE_ID \
                                --model $MODEL \
                                --backend $BACKEND \
                                --dataset $DATASET
echo "Finished running irrelevant file filtering"

#%% Retrieval-based localization
python agentless/fl/retrieve.py --index_type simple \
                                --filter_type given_files \
                                --filter_file results/$OUTPUT_DIR/file_level_irrelevant/loc_outputs.jsonl \
                                --output_folder results/$OUTPUT_DIR/retrievel_embedding \
                                --persist_dir embedding/swe-bench_simple \
                                --num_threads 10 \
                                --target_id $INSTANCE_ID \
                                --dataset $DATASET
echo "Finished running retrieval-based localization"

#%% Combine retrieval and model results
python agentless/fl/combine.py  --retrieval_loc_file results/$OUTPUT_DIR/retrievel_embedding/retrieve_locs.jsonl \
                                --model_loc_file results/$OUTPUT_DIR/file_level/loc_outputs.jsonl \
                                --top_n 3 \
                                --output_folder results/$OUTPUT_DIR/file_level_combined
echo "Finished running retrieval and model results combination"

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
                                --backend $BACKEND \
                                --dataset $DATASET
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
                                --backend $BACKEND \
                                --dataset $DATASET
echo "Finished running fine-grained line-level localization"

#%% Merge edit locations
python agentless/fl/localize.py --merge \
                                --output_folder results/$OUTPUT_DIR/edit_location_individual \
                                --top_n 3 \
                                --num_samples 4 \
                                --start_file results/$OUTPUT_DIR/edit_location_samples/loc_outputs.jsonl \
                                --target_id $INSTANCE_ID \
                                --model $MODEL \
                                --backend $BACKEND \
                                --dataset $DATASET
echo "Finished running edit locations merge"

#%% Repair for each set of edit locations
for i in {0..3}; do
    python agentless/repair/repair.py --loc_file results/$OUTPUT_DIR/edit_location_individual/loc_merged_${i}-${i}_outputs.jsonl \
                                    --output_folder results/$OUTPUT_DIR/repair_sample_agentless_localize_$((i+1)) \
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
                                    --backend $BACKEND \
                                    --dataset $DATASET
done
echo "Finished running repair for all edit locations"

set +e

# #%% Check each of the generated patches to see if any are bad
# cd ../../
# for i in {1..4}; do
#     folder=baselines/Agentless/results/$OUTPUT_DIR/repair_sample_$i
#     for ((num=0; num<$SAMPLES; num++)); do
#         # check for empty patch; skip if empty
#         file="${folder}/output_${num}_processed.jsonl"
#         if grep -q '"model_patch"[[:space:]]*:[[:space:]]*""' "$file"; then
#             echo "Patch $num is empty string, skipping"
#         else
#             run_id="check_bad_patch_${OUTPUT_DIR}_${i}_${num}"
#             python codearena.py --BugFixing --predictions_path="${folder}/output_${num}_processed.jsonl" \
#                                 --instance_ids $INSTANCE_ID \
#                                 --run_id=$run_id

#             # if it's a bad patch, add it to the dataset. returns 0 if bad and added, or 1 otherwise
#             python bad_patch_validation.py --results_folder $run_id \
#                                            --instance_id $INSTANCE_ID
#             # once bad patch found, stop testing the samples
#             if [ $? -eq 0 ]; then
#                 exit 0
#             fi
#         fi
#     done
# done

# no bad patch found, exit 1
exit 1

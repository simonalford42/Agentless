#%% Setup
TARGET_ID=$1
OUTPUT_DIR=$TARGET_ID
SAMPLES=1  # just one sample so that patch is more likely to be bad
MODEL="gpt-4o-mini-2024-07-18"

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

# #%% File-level localization
# python agentless/fl/localize.py --file_level \
#                                 --output_folder results/$OUTPUT_DIR/file_level \
#                                 --num_threads 10 \
#                                 --skip_existing \
#                                 --target_id $TARGET_ID \
#                                 --model $MODEL \
#                                 --dataset codearena_local
# echo "Finished running file-level localization"

# #%% Irrelevant file filtering
# python agentless/fl/localize.py --file_level \
#                                 --irrelevant \
#                                 --output_folder results/$OUTPUT_DIR/file_level_irrelevant \
#                                 --num_threads 10 \
#                                 --skip_existing \
#                                 --target_id $TARGET_ID \
#                                 --model $MODEL \
#                                 --dataset codearena_local
# echo "Finished running irrelevant file filtering"

# #%% Retrieval-based localization
# python agentless/fl/retrieve.py --index_type simple \
#                                 --filter_type given_files \
#                                 --filter_file results/$OUTPUT_DIR/file_level_irrelevant/loc_outputs.jsonl \
#                                 --output_folder results/$OUTPUT_DIR/retrievel_embedding \
#                                 --persist_dir embedding/swe-bench_simple \
#                                 --num_threads 10 \
#                                 --target_id $TARGET_ID \
#                                 --dataset codearena_local
# echo "Finished running retrieval-based localization"

# #%% Combine retrieval and model results
# python agentless/fl/combine.py  --retrieval_loc_file results/$OUTPUT_DIR/retrievel_embedding/retrieve_locs.jsonl \
#                                 --model_loc_file results/$OUTPUT_DIR/file_level/loc_outputs.jsonl \
#                                 --top_n 3 \
#                                 --output_folder results/$OUTPUT_DIR/file_level_combined
# echo "Finished running retrieval and model results combination"

# #%% Related elements localization
# python agentless/fl/localize.py --related_level \
#                                 --output_folder results/$OUTPUT_DIR/related_elements \
#                                 --top_n 3 \
#                                 --compress_assign \
#                                 --compress \
#                                 --start_file results/$OUTPUT_DIR/file_level_combined/combined_locs.jsonl \
#                                 --num_threads 10 \
#                                 --skip_existing \
#                                 --target_id $TARGET_ID \
#                                 --model $MODEL \
#                                 --dataset codearena_local
# echo "Finished running related elements localization"

# #%% Fine-grained line-level localization
# python agentless/fl/localize.py --fine_grain_line_level \
#                                 --output_folder results/$OUTPUT_DIR/edit_location_samples \
#                                 --top_n 3 \
#                                 --compress \
#                                 --temperature 0.8 \
#                                 --num_samples 4 \
#                                 --start_file results/$OUTPUT_DIR/related_elements/loc_outputs.jsonl \
#                                 --num_threads 10 \
#                                 --skip_existing \
#                                 --target_id $TARGET_ID \
#                                 --model $MODEL \
#                                 --dataset codearena_local
# echo "Finished running fine-grained line-level localization"

# #%% Merge edit locations
# python agentless/fl/localize.py --merge \
#                                 --output_folder results/$OUTPUT_DIR/edit_location_individual \
#                                 --top_n 3 \
#                                 --num_samples 4 \
#                                 --start_file results/$OUTPUT_DIR/edit_location_samples/loc_outputs.jsonl \
#                                 --target_id $TARGET_ID \
#                                 --model $MODEL \
#                                 --dataset codearena_local
# echo "Finished running edit locations merge"

# #%% Repair for each set of edit locations
# for i in {0..3}; do
#     python agentless/repair/repair.py --loc_file results/$OUTPUT_DIR/edit_location_individual/loc_merged_${i}-${i}_outputs.jsonl \
#                                     --output_folder results/$OUTPUT_DIR/repair_sample_$((i+1)) \
#                                     --loc_interval \
#                                     --top_n=3 \
#                                     --context_window=10 \
#                                     --max_samples $SAMPLES \
#                                     --cot \
#                                     --diff_format \
#                                     --gen_and_process \
#                                     --num_threads 2 \
#                                     --target_id $TARGET_ID \
#                                     --model $MODEL \
#                                     --dataset codearena_local
# done
# echo "Finished running repair for all edit locations"

# #%% Generate regression tests
# python agentless/test/run_regression_tests.py --run_id generate_regression_tests \
#                                             --output_file results/$OUTPUT_DIR/passing_tests.jsonl \
#                                             --instance_ids $TARGET_ID \
#                                             --dataset codearena_local
# echo "Finished running regression test generation"

# #%% Select regression tests
# python agentless/test/select_regression_tests.py --passing_tests results/$OUTPUT_DIR/passing_tests.jsonl \
#                                                 --output_folder results/$OUTPUT_DIR/select_regression \
#                                                --target_id $TARGET_ID \
#                                                --instance_ids $TARGET_ID \
#                                                --model $MODEL \
#                                                --dataset codearena_local
# echo "Finished running regression test selection"

# #%% Run regression tests on all patches
# for i in {1..4}; do
#     folder=results/$OUTPUT_DIR/repair_sample_$i
#     for ((num=0; num<$SAMPLES; num++)); do
#         run_id_prefix=$(basename $folder)
#         python agentless/test/run_regression_tests.py --regression_tests results/$OUTPUT_DIR/select_regression/output.jsonl \
#                                                       --predictions_path="${folder}/output_${num}_processed.jsonl" \
#                                                       --run_id="${run_id_prefix}_regression_${num}" \
#                                                       --num_workers 10 \
#                                                       --instance_ids $TARGET_ID \
#                                                       --dataset codearena_local
#     done
# done
# echo "Finished running regression tests on all patches"

#%% Rerank and select final patch
python agentless/repair/rerank.py --patch_folder results/$OUTPUT_DIR/repair_sample_1/,results/$OUTPUT_DIR/repair_sample_2/,results/$OUTPUT_DIR/repair_sample_3/,results/$OUTPUT_DIR/repair_sample_4/ \
                                --num_samples=$((4 * SAMPLES)) \
                                --deduplicate \
                                --regression \
                                --target $TARGET_ID \
                                --output_file results/$OUTPUT_DIR/all_preds.jsonl
echo "Successfully generated a patch using Agentless"

#%% Check that the patch is bad
cd ../../
python codearena.py --BugFixing --predictions_path baselines/Agentless/results/$OUTPUT_DIR/all_preds.jsonl --instance_ids $TARGET_ID --run_id check_bad_patch

#%% If patch is bad, add it to codearena_instances.json. returns 0 a patch is bad and added, or 1 otherwise.
python bad_patch_validation.py --predictions_path baselines/Agentless/results/$OUTPUT_DIR/all_preds.jsonl --instance_id $TARGET_ID --run_id check_bad_patch

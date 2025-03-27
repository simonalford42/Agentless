#%% Setup
OUTPUT_DIR=ytdl
TARGET_ID=ytdl-org__youtube-dl-32987
DATASET=codearena_local

#%% File-level localization
python agentless/fl/localize.py --file_level \
                                --output_folder results/$OUTPUT_DIR/file_level \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id $TARGET_ID \
                                --dataset $DATASET

#%% Irrelevant file filtering
python agentless/fl/localize.py --file_level \
                                --irrelevant \
                                --output_folder results/$OUTPUT_DIR/file_level_irrelevant \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id $TARGET_ID \
                                --dataset $DATASET

#%% Retrieval-based localization
python agentless/fl/retrieve.py --index_type simple \
                                --filter_type given_files \
                                --filter_file results/$OUTPUT_DIR/file_level_irrelevant/loc_outputs.jsonl \
                                --output_folder results/$OUTPUT_DIR/retrievel_embedding \
                                --persist_dir embedding/swe-bench_simple \
                                --num_threads 10 \
                                --target_id $TARGET_ID \
                                --dataset $DATASET

#%% Combine retrieval and model results
python agentless/fl/combine.py  --retrieval_loc_file results/$OUTPUT_DIR/retrievel_embedding/retrieve_locs.jsonl \
                                --model_loc_file results/$OUTPUT_DIR/file_level/loc_outputs.jsonl \
                                --top_n 3 \
                                --output_folder results/$OUTPUT_DIR/file_level_combined \

#%% Related elements localization
python agentless/fl/localize.py --related_level \
                                --output_folder results/$OUTPUT_DIR/related_elements \
                                --top_n 3 \
                                --compress_assign \
                                --compress \
                                --start_file results/$OUTPUT_DIR/file_level_combined/combined_locs.jsonl \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id $TARGET_ID \
                                --dataset $DATASET

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
                                --target_id $TARGET_ID \
                                --dataset $DATASET

#%% Merge edit locations
python agentless/fl/localize.py --merge \
                                --output_folder results/$OUTPUT_DIR/edit_location_individual \
                                --top_n 3 \
                                --num_samples 4 \
                                --start_file results/$OUTPUT_DIR/edit_location_samples/loc_outputs.jsonl \
                                --target_id $TARGET_ID \
                                --dataset $DATASET

#%% Repair for each set of edit locations
for i in {0..3}; do
    python agentless/repair/repair.py --loc_file results/$OUTPUT_DIR/edit_location_individual/loc_merged_${i}-${i}_outputs.jsonl \
                                    --output_folder results/$OUTPUT_DIR/repair_sample_$((i+1)) \
                                    --loc_interval \
                                    --top_n=3 \
                                    --context_window=10 \
                                    --max_samples 10 \
                                    --cot \
                                    --diff_format \
                                    --gen_and_process \
                                    --num_threads 2 \
                                    --target_id $TARGET_ID \
                                    --dataset $DATASET
done

#%% Generate regression tests
python agentless/test/run_regression_tests.py --run_id generate_regression_tests \
                                            --output_file results/$OUTPUT_DIR/passing_tests.jsonl \
                                            --target_id $TARGET_ID \
                                            --dataset $DATASET

#%% Select regression tests
python agentless/test/select_regression_tests.py --passing_tests results/$OUTPUT_DIR/passing_tests.jsonl \
                                               --output_folder results/$OUTPUT_DIR/select_regression \
                                               --target_id $TARGET_ID \
                                               --dataset $DATASET

#%% Run regression tests on all patches
for i in {1..4}; do
    folder=results/$OUTPUT_DIR/repair_sample_$i
    for num in {0..9..1}; do
        run_id_prefix=$(basename $folder)
        python agentless/test/run_regression_tests.py --regression_tests results/$OUTPUT_DIR/select_regression/output.jsonl \
                                                    --predictions_path="${folder}/output_${num}_processed.jsonl" \
                                                    --run_id="${run_id_prefix}_regression_${num}" \
                                                    --num_workers 10 \
                                                    --target_id $TARGET_ID \
                                                    --dataset $DATASET
    done
done

#%% Generate reproduction tests
python agentless/test/generate_reproduction_tests.py --max_samples 40 \
                                                   --output_folder results/$OUTPUT_DIR/reproduction_test_samples \
                                                   --num_threads 10 \
                                                   --target_id $TARGET_ID \
                                                   --dataset $DATASET

#%% Run reproduction tests on original repository
for st in {0..36..4}; do
    en=$((st + 3))
    echo "Processing ${st} to ${en}"
    for num in $(seq $st $en); do
        echo "Processing ${num}"
        python agentless/test/run_reproduction_tests.py --run_id="reproduction_test_generation_filter_sample_${num}" \
                                                      --test_jsonl="results/$OUTPUT_DIR/reproduction_test_samples/output_${num}_processed_reproduction_test.jsonl" \
                                                      --num_workers 6 \
                                                      --testing \
                                                      --target_id $TARGET_ID \
                                                      --dataset $DATASET
    done
done

#%% Select reproduction tests
python agentless/test/generate_reproduction_tests.py --max_samples 40 \
                                                   --output_folder results/$OUTPUT_DIR/reproduction_test_samples \
                                                   --output_file reproduction_tests.jsonl \
                                                   --select \
                                                   --target_id $TARGET_ID \
                                                   --dataset $DATASET

#%% Run reproduction tests on patches
for i in {1..4}; do
    folder=results/$OUTPUT_DIR/repair_sample_$i
    for num in {0..9..1}; do
        run_id_prefix=$(basename $folder)
        python agentless/test/run_reproduction_tests.py --test_jsonl results/$OUTPUT_DIR/reproduction_test_samples/reproduction_tests.jsonl \
                                                      --predictions_path="${folder}/output_${num}_processed.jsonl" \
                                                      --run_id="${run_id_prefix}_reproduction_${num}" \
                                                      --num_workers 10 \
                                                      --target_id $TARGET_ID \
                                                      --dataset $DATASET
    done
done

#%% Rerank and select final patches
python agentless/repair/rerank.py --patch_folder results/$OUTPUT_DIR/repair_sample_1/,results/$OUTPUT_DIR/repair_sample_2/,results/$OUTPUT_DIR/repair_sample_3/,results/$OUTPUT_DIR/repair_sample_4/ \
                                --num_samples 40 \
                                --deduplicate \
                                --regression \
                                --reproduction \
                                --target_id $TARGET_ID \
                                --dataset $DATASET
UTPUT_DIR=test
TARGET_ID=django__django-10914
DATASET=princeton-nlp/SWE-bench_Lite

#%% File-level localization
python agentless/fl/localize.py --file_level \
                                --output_folder results/$OUTPUT_DIR/file_level \
                                --num_threads 10 \
                                --skip_existing \

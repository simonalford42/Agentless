#%% Setup
INSTANCE_ID=$1
SAMPLES=$2
RUN_ID=$3
# 1 = line numbers, 2 = function names + line numbers, 3 = agentless localization
LOCALIZE_METHOD=$4
MODEL=$5
BACKEND=$6
DATASET=$7
LANGUAGE=$8

if [ "$LOCALIZE_METHOD" -eq 3 ]; then
    bash bad_patch_gen_agentless_localize.sh "$INSTANCE_ID" "$SAMPLES" "$RUN_ID"
    # exit with whatever the above command returned
    exit $?
fi

OUTPUT_DIR=${INSTANCE_ID}_n${SAMPLES}_$RUN_ID
# MODEL="gpt-4o-mini-2024-07-18"
# MODEL='gpt-4.1-nano'
# MODEL='gemini-2.5-flash-preview-04-17'
# MODEL='gemini-2.0-flash-lite'
# MODEL='gemini-1.5-flash'
# BACKEND='google' # 'openai', 'deepmind', etc.
# DATASET='codearena_local'
# LANGUAGE='python'
# DATASET='java_local'
# LANGUAGE='java'
# MODEL='gpt-4.1-mini'
# BACKEND='openai'


# add cd to path
export PYTHONPATH=$PYTHONPATH:$(pwd)
# do the same for codearena repo so we can access monkeypatched swebench
cd ../../
export PYTHONPATH=$PYTHONPATH:$(pwd)
cd baselines/Agentless

set -e

python agentless/fl/gold_localize.py --target_id "$INSTANCE_ID" \
  --output_folder "results/$OUTPUT_DIR/edit_location_individual" \
  --output_file "gold_loc_outputs$LOCALIZE_METHOD.jsonl" \
  --dataset $DATASET \
  $( [ "$LOCALIZE_METHOD" -eq 2 ] && echo --include_fn_name )
echo "Localization done"

python agentless/repair/repair.py --loc_file results/$OUTPUT_DIR/edit_location_individual/gold_loc_outputs$LOCALIZE_METHOD.jsonl \
                                --output_folder results/$OUTPUT_DIR/repair_sample$LOCALIZE_METHOD \
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
                                --dataset $DATASET \
                                --language $LANGUAGE \
                                --skip_greedy
echo "Repair done"

set +e

#%% Check each of the generated patches to see if any are bad
cd ../../
folder=baselines/Agentless/results/$OUTPUT_DIR/repair_sample$LOCALIZE_METHOD
for ((num=0; num<$SAMPLES; num++)); do
    # check for empty patch; skip if empty
    file="${folder}/output_${num}_processed.jsonl"
    if grep -q '"model_patch"[[:space:]]*:[[:space:]]*""' "$file"; then
        echo "Patch $num is empty string, skipping"
    else
        run_id="check_bad_patch_${OUTPUT_DIR}_${LOCALIZE_METHOD}_${num}"

        # if using java, we need to run the codearena.py script with a different instance id format
        if [ "$LANGUAGE" == "java" ]; then
            INSTANCE_ID_NEW=$(echo "$INSTANCE_ID" | sed -E 's/^([^_]*)__([^_]*)_(.*)$/\1\/\2:\3/')

            echo "running codearena.py with instance id $INSTANCE_ID_NEW, file $file, run_id $run_id, and localization method $LOCALIZE_METHOD"

            # run tests to see if it's a bad patch
            python codearena.py --MSWEBugFixing \
                                --predictions_path=$file \
                                --instance_ids $INSTANCE_ID_NEW \
                                --run_id=$run_id \
                                --mswe_phase 'all' \

            # if it's a bad patch, add it to the dataset. returns 0 if bad and added, or 1 otherwise
            python bad_patch_validation.py  --results_folder $run_id \
                                            --instance_id $INSTANCE_ID \
                                            --language $LANGUAGE \
            # once bad patch found, stop testing the samples
            if [ $? -eq 0 ]; then
                echo "Bad patch found for sample $num with localization method $LOCALIZE_METHOD"
                exit 0
            fi
        else
            # run tests to see if it's a bad patch
            python codearena.py --BugFixing \
                                --predictions_path=$file \
                                --instance_ids $INSTANCE_ID \
                                --run_id=$run_id

            # if it's a bad patch, add it to the dataset. returns 0 if bad and added, or 1 otherwise
            python bad_patch_validation.py --results_folder $run_id \
                                        --instance_id $INSTANCE_ID
            # once bad patch found, stop testing the samples
            if [ $? -eq 0 ]; then
                echo "Bad patch found for sample $num with localization method $LOCALIZE_METHOD"
                exit 0
            fi
        fi
    fi
done

# no bad patch found, exit 1
exit 1

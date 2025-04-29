INSTANCE_ID=$1
SAMPLES=$2
RUN_ID=$3

# line level bad patch gen
bash bad_patch_gen.sh "$INSTANCE_ID" "$SAMPLES" "$RUN_ID" 1

# # if line level worked, then stop
# if [ $? -eq 0 ]; then
#     exit 0
# fi

echo "Trying function name localization"
bash bad_patch_gen.sh "$INSTANCE_ID" "$SAMPLES" "$RUN_ID" 2

# # if fn name worked, then stop
# if [ $? -eq 0 ]; then
#     exit 0
# fi

# # if it returned 1, then try agentless localization (just 3 samples)
# echo "Trying agentless localization"
# bash bad_patch_gen.sh "$INSTANCE_ID" 3 "$RUN_ID" 3

# if [ $? -eq 0 ]; then
#     exit 0
# fi

# echo "No Bad patch found for task $INSTANCE_ID"
# exit 1

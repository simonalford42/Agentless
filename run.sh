run_id=still_need_todo

while IFS= read -r line; do
    line_number=$((line_number + 1))
    echo "Processing line $line_number: $line"
    current_datetime=$(date +"%Y%m%d_%H%M%S")
    logfile="logs/bad_patch_gen/${run_id}_3_${line}_${current_datetime}.txt"
    echo "Saving output to $logfile"
    bash bad_patch_gen_agentless_localize.sh "$line" 4 "$run_id" > $logfile 2>&1
done < still_need_ids.txt

# bash full_bad_patch_gen.sh 'astropy__astropy-12907' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-13033' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-13236' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-13398' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-13453' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-13579' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-13977' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-14096' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-14182' 10 $run_id
# bash full_bad_patch_gen.sh 'astropy__astropy-14309' 10 $run_id

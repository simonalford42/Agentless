# run_id=all_tasks5

# while IFS= read -r line; do
#     line_number=$((line_number + 1))
#     echo "Processing line $line_number: $line"
#     current_datetime=$(date +"%Y%m%d_%H%M%S")
#     bash bad_patch_gen_agentless_localize.sh "$line" 3 "$run_id" > "logs/bad_patch_gen/${run_id}_3_${line}_${current_datetime}.txt" 2>&1
# done < instance_ids.txt

bash bad_patch_gen.sh matplotlib__matplotlib-24149 10 all_tasks3_v2 1
bash bad_patch_gen.sh django__django-15851 10 all_tasks3_v2 1
bash bad_patch_gen.sh sympy__sympy-22714 10 all_tasks3_v2 1
bash bad_patch_gen.sh matplotlib__matplotlib-24149 10 all_tasks3_v2 2
bash bad_patch_gen.sh django__django-15851 10 all_tasks3_v2 2
bash bad_patch_gen.sh sympy__sympy-22714 10 all_tasks3_v2 2

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

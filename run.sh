run_id=$1

# while IFS= read -r line; do
#     line_number=$((line_number + 1))
#     echo "Processing line $line_number: $line"
#     current_datetime=$(date +"%Y%m%d_%H%M%S")
#     logfile="logs/bad_patch_gen/${run_id}_3_${line}_${current_datetime}.txt"
#     echo "Saving output to $logfile"
#     bash bad_patch_gen_agentless_localize.sh "$line" 4 "$run_id" > $logfile 2>&1
# done < still_need_ids.txt

# bash full_bad_patch_gen.sh statsmodels__statsmodels-9487 5 $run_id
# bash full_bad_patch_gen.sh pallets__flask-5014 5 $run_id
# bash full_bad_patch_gen.sh ytdl-org__youtube-dl-32987 5 $run_id
# bash full_bad_patch_gen.sh sympy__sympy-24661 5 $run_id
# bash full_bad_patch_gen.sh fastapi__fastapi-4871 5 $run_id
# bash full_bad_patch_gen.sh camel-ai__camel-1246 5 $run_id
# bash full_bad_patch_gen.sh mwaskom__seaborn-3187 5 $run_id
# bash full_bad_patch_gen.sh pylint-dev__pylint-4551 5 $run_id
# bash full_bad_patch_gen.sh sphinx-doc__sphinx-11510 5 $run_id
# bash full_bad_patch_gen.sh scrapy__scrapy-6388 5 $run_id
# bash full_bad_patch_gen.sh django__django-10554 5 $run_id
# bash full_bad_patch_gen.sh psf__requests-1142 5 $run_id

runs=4

bash full_bad_patch_gen.sh astropy__astropy-13236 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-13033 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-13398 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-13453 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-13579 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-14096 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-14182 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-14369 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-14508 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-14539 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-14598 $runs $run_id
bash full_bad_patch_gen.sh astropy__astropy-14995 $runs $run_id
bash full_bad_patch_gen.sh django__django-11141 $runs $run_id
bash full_bad_patch_gen.sh django__django-11206 $runs $run_id
bash full_bad_patch_gen.sh django__django-11603 $runs $run_id
bash full_bad_patch_gen.sh django__django-11740 $runs $run_id
bash full_bad_patch_gen.sh django__django-11848 $runs $run_id
bash full_bad_patch_gen.sh django__django-12308 $runs $run_id
bash full_bad_patch_gen.sh django__django-12325 $runs $run_id
bash full_bad_patch_gen.sh django__django-12406 $runs $run_id
bash full_bad_patch_gen.sh django__django-12713 $runs $run_id



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

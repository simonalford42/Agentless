run_id=batch3
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-32987' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-32725' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-31182' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-32845' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-32741' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-31235' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-30582' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-29698' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-28801' 1 $run_id
# bash bad_patch_gen.sh 'ytdl-org__youtube-dl-23199' 1 $run_id
# bash bad_patch_gen.sh 'keras-team__keras-20443' 1 $run_id
# bash bad_patch_gen.sh 'keras-team__keras-20380' 1 $run_id
# bash bad_patch_gen.sh 'keras-team__keras-20534' 1 $run_id

# list=('keras-team__keras-20791' \
#  'keras-team__keras-19284' \
#  'keras-team__keras-20689' \
#  'keras-team__keras-19300' \
#  'keras-team__keras-18977' \
#  'keras-team__keras-19826' \
#  'keras-team__keras-19863' \
#  'keras-team__keras-18526' \
#  'keras-team__keras-20609' \
#  'keras-team__keras-19641')

# list=('ytdl-org__youtube-dl-32987' 'ytdl-org__youtube-dl-32845' 'ytdl-org__youtube-dl-32741' 'ytdl-org__youtube-dl-32725' 'ytdl-org__youtube-dl-31235' 'ytdl-org__youtube-dl-31182' 'ytdl-org__youtube-dl-30582' 'ytdl-org__youtube-dl-29698' 'ytdl-org__youtube-dl-28801' 'ytdl-org__youtube-dl-23199')
# for id in "${list[@]}"; do
#     # bash full_check.sh "$id" 10 "$run_id"
#     bash full_bad_patch_gen.sh "$id" 10 "$run_id"
# done

bash full_bad_patch_gen.sh ytdl-org__youtube-dl-32987 10 gemini

# bash run2.sh 'keras-team__keras-19773' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-19773_n3_test_2
    # Bad patch found for sample 2 with localization method 1
# bash run2.sh 'keras-team__keras-19102' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-19102_n3_test_1
    # Bad patch found for sample 1 with localization method 1
# bash run2.sh 'keras-team__keras-20076' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-20076_n3_test_0
    # Bad patch found for sample 0 with localization method 1
# bash run2.sh 'keras-team__keras-18852' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-18852_n3_test_0
    # Bad patch found for sample 0 with localization method 1
# bash run2.sh 'keras-team__keras-20815' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-20815_n3_test_0
    # Bad patch found for sample 0 with localization method 1
# bash run2.sh 'keras-team__keras-19484' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-19484_n3_test_0
    # Bad patch found for sample 0 with localization method 1
# bash run2.sh 'keras-team__keras-20537' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-20537_n3_test_0
    # Bad patch found for sample 0 with localization method 1

# bash run2.sh 'keras-team__keras-19931' 10 $run_id
#     # nothing found
# bash run2.sh 'keras-team__keras-18585' 10 $run_id
#     # nothing found

# bash run2.sh 'keras-team__keras-20808' 3 $run_id
    # Bad patch successfully added to dataset from: logs/run_evaluation/check_bad_patch_keras-team__keras-20808_n3_test2_1
    # Bad patch found for sample 1 with localization method 1

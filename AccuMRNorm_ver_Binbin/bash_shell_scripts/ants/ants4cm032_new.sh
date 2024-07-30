#!/bin/bash
#
ana_input='/mnt/d/CM032_bids/sub-CM032/anat/csub-CM032_run-03_FLASH_BETss.nii'
template='/mnt/d/AccuMRnorm_binbin/NMT_v2.0/NMT_v2.0_sym_SS.nii'
post_landmark_flow_field='/mnt/d/CM032_bids/sub-CM032/norm/u_rc2wrsssub-CM032_run-03_FLASHdesc_ss_ref(NMT_v2.0_sym_SS)_mreg2d_volume_Template.nii'



func_mean='/mnt/d/CM032_bids/sub-CM032/func/meanrsub-CM032_run-02_EPI.nii'

analysis_dir='/mnt/d/CM032_bids_NEW/sub-CM032/first_level_analysis'
cd $analysis_dir

func_orig='/mnt/d/CM032_bids_NEW/sub-CM032/func'
mkdir func_copy
cp -r $func_orig/r* ./func_copy

mkdir warped_ana
mkdir warped_funcs
warped_ana='ana2temp'

antsRegistrationSyN.sh -d 3 -m $ana_input -f $template -o -a warped_ana/nosyn



for func in "${funcs[@]}"; do
    # Check if $func contains ".gz"
    if [[ $func != *.gz ]]; then
        gzipped_func="${func}.gz"
    else
        gzipped_func="$func"
        $func=${$func%.gz}
    fi

    # antsApplyTransforms command using $gzipped_func
    antsApplyTransforms -d 3 -e 3 -i "$gzipped_func" -r "$func_mean" \
        -t ./Ana2Temp/with_landmark_0Warp.nii.gz -t ./Ana2Temp/with_landmark_1GenericAffine.mat \
        -t ./Ana2Temp/with_landmark_2Warp.nii.gz -o "./warped_funcs/warped_$(basename "$func").nii"
done
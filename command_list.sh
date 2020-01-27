## Initiate virtual enviroment
#source venv/bin/activate
#
## Make all files executable
#chmod -R +x ./
#
## Run python scripts
## ----------------------------- Getting data -------------------------------------
## Download data from network-attached storage (MLMH lab use only)
./download_data.py -N "/run/user/1000/gvfs/smb-share:server=kc-deeplab.local,share=deeplearning/"
./download_ants_data.py -N "/run/user/1000/gvfs/smb-share:server=kc-deeplab.local,share=deeplearning/" -S "SCANNER01" -O "/media/kcl_1/SSD2/BIOBANK"
./download_ants_data.py -N "/run/user/1000/gvfs/smb-share:server=kc-deeplab.local,share=deeplearning/" -S "SCANNER02" -O "/media/kcl_1/HDD/DATASETS/BIOBANK"

# ----------------------------- Preprocessing ------------------------------------
# Clean UK Biobank data.
./preprocessing_clean_data.py -E "biobank_scanner1" -S "SCANNER01"
./preprocessing_clean_data.py -E "biobank_scanner2" -S "SCANNER02"

# Perform quality control.
./preprocessing_quality_control.py -E "biobank_scanner1" -S "SCANNER01"
./preprocessing_quality_control.py -E "biobank_scanner2" -S "SCANNER02"

# Make gender homogeneous along age range (performed only in the scanner1
# because we were concerned in not create a biased regressor).
./preprocessing_homogenize_gender.py -E "biobank_scanner1" -S "SCANNER01"

# Create kernel matrix for voxel-based analysis
./preprocessing_compute_kernel_matrix.py -P "/media/kcl_1/SSD2/BIOBANK" -E "biobank_scanner1"

# Create pca models
./preprocessing_compute_principal_components.py -P "/media/kcl_1/SSD2/BIOBANK" -E "biobank_scanner1" -S "SCANNER01"

# ----------------------------- Regressors comparison ------------------------------------
./comparison_fs_data_train_svm.py -E "biobank_scanner1" -S "SCANNER01"
./comparison_fs_data_train_rvm.py -E "biobank_scanner1" -S "SCANNER01"
./comparison_fs_data_train_gp.py -E "biobank_scanner1" -S "SCANNER01"

./comparison_voxel_data_train_svm.py -E "biobank_scanner1" -S "SCANNER01"
./comparison_voxel_data_train_rvm.py -E "biobank_scanner1" -S "SCANNER01"

./comparison_voxel_data_svm_primal_weights.py -E "biobank_scanner1" -P "/media/kcl_1/SSD2/BIOBANK"
./comparison_feature_importance_visualisation.py

./comparison_statistical_analsysis.py -E "biobank_scanner1" -S "_all" -M "SVM" "RVM" "GPR" "voxel_SVM" "voxel_RVM"

## ----------------------------- Generalization comparison -----------------------
./generalisation_test_fs_data.py -T "biobank_scanner1" -G "biobank_scanner2" -S "SCANNER02" -M "SVM" -I 'cleaned_ids.csv'
./generalisation_test_fs_data.py -T "biobank_scanner1" -G "biobank_scanner2" -S "SCANNER02" -M "RVM" -I 'cleaned_ids.csv'
./generalisation_test_fs_data.py -T "biobank_scanner1" -G "biobank_scanner2" -S "SCANNER02" -M "GPR" -I 'cleaned_ids.csv'

./generalisation_test_voxel_data.py -T "biobank_scanner1" -G "biobank_scanner2" -S "SCANNER02" -M "voxel_SVM" -P "/media/kcl_1/HDD/DATASETS/BIOBANK/BIOBANK"

./comparison_statistical_analsysis.py -E "biobank_scanner2" -S "_generalization" -M "SVM" "RVM" "GPR" "voxel_SVM" "voxel_RVM"

# ----------------------------- Sample size analysis ------------------------------------
./sample_size_create_ids.py -E "biobank_scanner1" -S "SCANNER01"

./sample_size_fs_data_svm_analysis.py -E "biobank_scanner1" -S "SCANNER01"
./sample_size_fs_data_gp_analysis.py -E "biobank_scanner1" -S "SCANNER01"
./sample_size_fs_data_rvm_analysis.py -E "biobank_scanner1" -S "SCANNER01"

./sample_size_voxel_data_rvm_analysis.py -E "biobank_scanner1" -S "SCANNER01"
./sample_size_voxel_data_svm_analysis.py -E "biobank_scanner1" -S "SCANNER01"

./sample_size_create_figures.py -E "biobank_scanner1" -M "SVM"
./sample_size_create_figures.py -E "biobank_scanner1" -M "RVM"
./sample_size_create_figures.py -E "biobank_scanner1" -M "GPR"
./sample_size_create_figures.py -E "biobank_scanner1" -M "voxel_SVM"
./sample_size_create_figures.py -E "biobank_scanner1" -M "voxel_RVM"

# ----------------------------- Permutation ------------------------------------
./permutation_lauch_subprocesses.py -E "biobank_scanner1" -S "SCANNER01"
./permutation_significance_test.py

# ----------------------------- Covariates analysis ------------------------------------
./covariates_create_variables_biobank.py
./covariates_create_variables_indices_of_deprivation.py
./covariates_ensemble_output.py
./covariates_lsoa_corr.py
./covariates_statistical_analysis.py

# ----------------------------- Miscelanious ------------------------------------
# Univariate analysis on freesurfer data
./misc_univariate_analysis.py -E "biobank_scanner1" -S "SCANNER01"

./misc_classifier_train_svm.py
./misc_classifier_regressor_comparison.py

# Performance of different values of the SVM hyperparameter (C)
./misc_svm_hyperparameters_analysis.py -E "biobank_scanner1"

# ----------------------------- Exploratory Data Analysis ------------------------------------
./eda_demographic_data.py -E "biobank_scanner1" -S "SCANNER01" -U "_homogenized" -I 'homogenized_ids.csv'
./eda_demographic_data.py -E "biobank_scanner2" -S "SCANNER02" -U "_cleaned" -I 'cleaned_ids.csv'
./eda_education_age.py
#!/bin/bash

# ENVIRONMENT VARIABLES

WORKING_DIRECTORY="${HOME}/qpb_branches/Chebyshev_modified_eigenvalues/qpb/mainprogs/overlap-Chebyshev/ginsparg-wilson-relation"
PARAMETER_FILES_DIRECTORY="$WORKING_DIRECTORY/params_files"
# LOG_FILES_DIRECTORY="$WORKING_DIRECTORY/log_files"
SMEARED_CONFIGURATIONS_DIRECTORY="/onyx/qdata/Nf0_b6p20_L24T48-APE"

# GAUGE_LINKS_CONFIGURATIONS_DIRECTORY="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE"

# USEFUL LISTS

MODIFIABLE_PARAMETER_NAMES_ARRAY=("OPERATOR_TYPE" "CONFIG_LABEL" "APE_ITERS" "RHO" "NUMBER_OF_TERMS" "LANCZOS_EPSILON" "DELTA_MAX" "DELTA_MIN")

OPERATOR_METHODS_ARRAY=("Bare" "KL" "Chebyshev") # Bare must be the 1st element

OPERATOR_TYPES_ARRAY=("Standard" "Brillouin")

NON_SMEARED_CONFIG_LABELS_ARRAY=("002" "066" "130" "194" "258" "322" "386" "450" "514" "578" "642" "706")

LATTICE_DIMENSIONS_LIST=("24 12 12 12" "32 16 16 16" "40 20 20 20" "48 24 24 24")

# TYPICAL VALUES OF MODIFIABLE PARAMETERS

# CONFIG_LABEL="002"
# CONFIGURATION_FILE_FULL_PATH="/nvme/h/cy22sg1/scratch/Nf0/Nf0_b6p20_L24T48-APE/conf_Nf0_b6p20_L24T48_apeN1a0p72.0024200"

# These are exactly the parameters as they appear in the parameter files lines
GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH="0000000" # Invalid value to indicate for the use of the very first file in the "GAUGE_LINKS_CONFIGURATIONS_DIRECTORY"
LATTICE_DIMENSIONS="48 24 24 24"
NUMBER_OF_VECTORS="1"
APE_ITERATIONS="0"
APE_ALPHA="0.72"
RHO="1.0"
BARE_MASS="0.0"
CLOVER_TERM_COEFFICIENT="1"
OPERATOR_TYPE="Standard"
NUMBER_OF_CHEBYSHEV_TERMS=10
KL_DIAGONAL_NUMBER="1"
SOLVER_EPSILON="1e-8"
SOLVER_MAX_ITERATIONS="10000"
LANCZOS_EPSILON="1e-8"
LANCZOS_MAX_ITERATIONS="10000"
DELTA_MIN="1.0"
DELTA_MAX="1.0"
SCALING_FACTOR="1.0"

# Define the list of replacement variables
MODIFIABLE_PARAMETERS_LIST=(
        "LATTICE_DIMENSIONS" \
        "GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH" \
        "NUMBER_OF_VECTORS" \
        "APE_ITERATIONS" \
        "APE_ALPHA" \
        "RHO" \
        "BARE_MASS" \
        "CLOVER_TERM_COEFFICIENT" \
        "OPERATOR_TYPE" \
        "NUMBER_OF_CHEBYSHEV_TERMS" \
        "KL_DIAGONAL_NUMBER" \
        "SOLVER_EPSILON" \
        "SOLVER_MAX_ITERATIONS" \
        "LANCZOS_EPSILON" \
        "LANCZOS_MAX_ITERATIONS" \
        "DELTA_MIN" \
        "DELTA_MAX" \
        "SCALING_FACTOR"
    )

MODIFIABLE_PARAMETERS_LABELS_LIST=(
        "LatticeDims" \
        "config" \
        "NVecs" \
        "APEiters" \
        "APEalpha" \
        "rho" \
        "m" \
        "cSW" \
        "OPERATOR_TYPE" \
        "N" \
        "n" \
        "EpsCG" \
        "CGMaxIters" \
        "EpsLanczos" \
        "LanczosMaxIters" \
        "dMin" \
        "dMax" \
        "mu"
    )

declare -A MODIFIABLE_PARAMETERS_LABELS_DICTIONARY

MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"]="config"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["LATTICE_DIMENSIONS"]="LatticeDims"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["NUMBER_OF_VECTORS"]="NVecs"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["APE_ITERATIONS"]="APEiters"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["APE_ALPHA"]="APEalpha"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["RHO"]="rho"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["BARE_MASS"]="m"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["CLOVER_TERM_COEFFICIENT"]="cSW"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["OPERATOR_TYPE"]="OPERATOR_TYPE"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["NUMBER_OF_CHEBYSHEV_TERMS"]="N"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["KL_DIAGONAL_NUMBER"]="n"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["SOLVER_EPSILON"]="EpsCG"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["SOLVER_MAX_ITERATIONS"]="CGMaxIters"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["LANCZOS_EPSILON"]="EpsLanczos"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["LANCZOS_MAX_ITERATIONS"]="LanczosMaxIters"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["DELTA_MIN"]="dMin"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["DELTA_MAX"]="dMax"
MODIFIABLE_PARAMETERS_LABELS_DICTIONARY["SCALING_FACTOR"]="mu"

declare -A MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY

MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["LATTICE_DIMENSIONS"]="check_lattice_dimensions"
# TODO: Do I really need a function to check configuration labels?
# MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"]=""
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["NUMBER_OF_VECTORS"]="is_positive_integer"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["APE_ITERATIONS"]="is_non_negative_integer"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["APE_ALPHA"]="is_positive_float"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["RHO"]="check_rho_value"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["BARE_MASS"]="is_float"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["CLOVER_TERM_COEFFICIENT"]="check_clover_term_coefficient_value"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["OPERATOR_TYPE"]="check_operator_type"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["NUMBER_OF_CHEBYSHEV_TERMS"]="is_positive_integer"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["KL_DIAGONAL_NUMBER"]="is_positive_integer"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["SOLVER_EPSILON"]="is_positive_float"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["SOLVER_MAX_ITERATIONS"]="is_positive_integer"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["LANCZOS_EPSILON"]="is_positive_float"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["LANCZOS_MAX_ITERATIONS"]="is_positive_integer"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["DELTA_MIN"]="is_positive_float"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["DELTA_MAX"]="is_positive_float"
MODIFIABLE_PARAMETERS_CHECK_FUNCTION_DICTIONARY["SCALING_FACTOR"]="is_positive_float"


declare -A MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY

MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["LATTICE_DIMENSIONS"]="lattice_dimensions_range_of_strings_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["GAUGE_LINKS_CONFIGURATION_FILE_FULL_PATH"]="range_of_gauge_configurations_file_paths_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["NUMBER_OF_VECTORS"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["APE_ITERATIONS"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["APE_ALPHA"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["RHO"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["BARE_MASS"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["CLOVER_TERM_COEFFICIENT"]="general_range_of_values_generator"
# TODO: Do I really need a range generator for operator type?
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["OPERATOR_TYPE"]=""
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["NUMBER_OF_CHEBYSHEV_TERMS"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["KL_DIAGONAL_NUMBER"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["SOLVER_EPSILON"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["SOLVER_MAX_ITERATIONS"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["LANCZOS_EPSILON"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["LANCZOS_MAX_ITERATIONS"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["DELTA_MIN"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["DELTA_MAX"]="general_range_of_values_generator"
MODIFIABLE_PARAMETERS_RANGE_OF_VALUES_GENERATOR_DICTIONARY["SCALING_FACTOR"]="general_range_of_values_generator"

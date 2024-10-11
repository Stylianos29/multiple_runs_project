#!/bin/bash


######################################################################
# main_scripts/setup.sh - Script for setting up the multiple runs project
#
# This script automates the setup of the multiple runs project by copying
# essential scripts and configuration files to a specified destination
# directory. It ensures that all required files are present, appropriately
# modified, and placed in a newly created "multiple_runs_scripts" directory
# inside the destination.
#
# The script checks for valid command-line arguments, creates necessary
# directories, and updates file contents based on the destination path.
#
# Files copied include:
#   1. "multiple_runs.sh" - The main script for running multiple jobs, with a
#      warning appended that it is auto-generated.
#   2. "input.txt" - Configuration file, with its paths and modifiable
#      parameters automatically updated.
#   3. "_params.ini_" - An empty parameters file selected based on the
#      destination path.
#   4. "update.sh" - Script for updating the copied files, with its path
#      auto-filled and a warning appended.
#
# The script logs all actions and outputs errors if any steps fail.
#
# Usage: ./setup.sh -p <destination_directory> [-u|--usage]
#
# Notes:
#   - The destination directory must be provided as an argument.
#   - The appropriate "_params.ini_" file is chosen based on the destination
#     path.
#   - The script appends auto-generated warnings to "multiple_runs.sh" and
#     "update.sh".
#   - All actions are logged, and the script exits if any errors occur.
#
######################################################################


# ENVIRONMENT VARIABLES

# NOTE: The log file must be placed in the same directory as the script.
# Since "setup.sh" may be executed directly or sourced from another script,
# the script's full path is checked to construct the log file path correctly.

# Use the current script's path unless it's already set by another script
if [ -z "$CURRENT_SCRIPT_FULL_PATH" ]; then
    CURRENT_SCRIPT_FULL_PATH="$0"
fi
# Extract the script name from the full path
CURRENT_SCRIPT_NAME="$(basename "$CURRENT_SCRIPT_FULL_PATH")"
# Replace ".sh" with "_log.txt" to create the log file name
LOG_FILE_NAME=$(echo "$CURRENT_SCRIPT_NAME" | sed 's/\.sh$/_log.txt/')
LOG_FILE_PATH="$(dirname "$CURRENT_SCRIPT_FULL_PATH")/${LOG_FILE_NAME}"

# Create or override a log file. Initiate logging
echo -e "\t\t"$(echo "$CURRENT_SCRIPT_NAME" | tr '[:lower:]' '[:upper:]') \
                "SCRIPT EXECUTION INITIATED\n" > "$LOG_FILE_PATH"

# Extract full path of directory containing current script. "${BASH_SOURCE[0]}"
# ensures the correct path is obtained even when script is sourced.
MAIN_SCRIPTS_DIRECTORY_FULL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all custom functions scripts from "multiple_runs_project/library" using
# a loop avoiding this way name-specific sourcing and thus potential typos
sourced_scripts_count=0 # Initialize a counter for sourced files
for custom_functions_script in $(realpath \
                        "$MAIN_SCRIPTS_DIRECTORY_FULL_PATH/../library"/*.sh);
do
    # Check if the current file in the loop is a regular file
    if [ -f "$custom_functions_script" ]; then
        source "$custom_functions_script"
        ((sourced_scripts_count++)) # Increment counter for each sourced script
    fi
done

# Script termination message to be used for finalizing logging
SCRIPT_TERMINATION_MESSAGE="\n\t\t"$(echo "$CURRENT_SCRIPT_NAME" \
                    | tr '[:lower:]' '[:upper:]')" SCRIPT EXECUTION TERMINATED"

# Check whether any files were sourced
if [ $sourced_scripts_count -gt 0 ]; then
    log "INFO" "A total of $sourced_scripts_count custom functions scripts "\
"were successfully sourced."
else
    ERROR_MESSAGE="No custom functions scripts were sourced at all."
    echo "ERROR: "$ERROR_MESSAGE
    echo "Exiting..."
    # Log error explicitly since "log()" function couldn't be sourced
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] : $ERROR_MESSAGE" \
                                                            >> "$LOG_FILE_PATH"
    echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"
    exit 1
fi

# COMMAND-LINE ARGUMENTS CHECKS
# Check if no arguments were passed
if [[ "$#" -eq 0 ]]; then
    ERROR_MESSAGE="No command-line arguments were provided at all."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    setup_script_usage
fi
# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # Match the -p or --path option, expecting a directory argument after it
        -p|--path)
            if [[ -n $2 && $2 != -* ]]; then
                DESTINATION_DIRECTORY_PATH=$2
                shift  # Skip the next argument as it's the path
            else
                ERROR_MESSAGE="Argument for $1 is missing."
                termination_output "${ERROR_MESSAGE}" \
                                            "${SCRIPT_TERMINATION_MESSAGE}"
                setup_script_usage
            fi
            ;;
        # Match the -u or --usage option to display usage
        -u|--usage)
            log "WARNING" "Usage option invoked thus no further action allowed."
            echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"
            setup_script_usage  # Call the usage function to display help
            ;;
        # Handle unknown options
        -*)
            ERROR_MESSAGE="Unknown option: $1."
            termination_output "${ERROR_MESSAGE}" \
                                                "${SCRIPT_TERMINATION_MESSAGE}"
            setup_script_usage
            ;;
        # Break the loop if no more options are found
        *)
            break
            ;;
    esac
    shift  # Move to the next argument
done

# Check if destination directory exists. If not, exit with warning
if [ ! -d "$DESTINATION_DIRECTORY_PATH" ]; then
    ERROR_MESSAGE="Destination directory does not exist. Please check again."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
log "INFO" "Destination directory path is: '"${DESTINATION_DIRECTORY_PATH}"'."

# All files will be copied to the "multiple_runs_scripts" directory in the
# destination directory. It will be created if it doesn't exist.
MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH=${DESTINATION_DIRECTORY_PATH}\
"/multiple_runs_scripts"
if [ ! -d "$MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH" ]; then
    mkdir -p "$MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH"
    log "INFO" \
    "'multiple_runs_scripts' directory created inside destination directory."
fi


# COPY ALL NECESSARY FILES TO DESTINATION MODIFIED APPROPRIATELY IF NECESSARY

# 1. "multiple_runs.sh" script
ORIGINAL_FILE="multiple_runs.sh"
check_if_file_exists $ORIGINAL_FILE \
                        "Original $ORIGINAL_FILE file cannot be located." \
                        "${SCRIPT_TERMINATION_MESSAGE}"
# NOTE: Line "MULTIPLE_RUNS_PROJECT_DIRECTORY_FULL_PATH=" of original
# "multiple_runs.sh" is auto-filled
sed -i \
"s|^\(MULTIPLE_RUNS_PROJECT_DIRECTORY_FULL_PATH=\).*|\1\"\
$(dirname $MAIN_SCRIPTS_DIRECTORY_FULL_PATH)\"|" "$ORIGINAL_FILE"
cp $ORIGINAL_FILE $MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH
if [ $? -ne 0 ]; then
    ERROR_MESSAGE="Copying '$ORIGINAL_FILE' file failed."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
# NOTE: A warning is appended to the copied "multiple_runs.sh" read-only script
WARNING_MESSAGE=\
"\n\n#======================================================================
\n# This script is auto-generated and should not be modified manually.
\n# ====================================================================="
copied_multiple_runs_script_full_path=${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}\
"/multiple_runs.sh"
target_line="#!/bin/bash"
insert_message $copied_multiple_runs_script_full_path $target_line \
                                                                $WARNING_MESSAGE
# Make copied "multiple_runs.sh" script an executable
chmod +x $copied_multiple_runs_script_full_path
log "INFO" "'$ORIGINAL_FILE' script was copied successfully."

# 2. "input.txt" text file
ORIGINAL_FILE=input.txt
check_if_file_exists $ORIGINAL_FILE \
                        "Original $ORIGINAL_FILE file cannot be located." \
                        "${SCRIPT_TERMINATION_MESSAGE}"
cp $ORIGINAL_FILE $MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH
if [ $? -ne 0 ]; then
    ERROR_MESSAGE="Copying '$ORIGINAL_FILE' file failed."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
# NOTE: A list of all the parameters and their values is inserted in the copy
modifiable_parameters=$(print_list_of_modifiable_parameters)
# Initialize an empty variable to hold the formatted output
formatted_parameters=""
# Process each line of the captured output
while IFS= read -r line; do
    formatted_parameters+="#$line\n"
done <<< "$modifiable_parameters"
# Pass
insert_message "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE" \
                    "# List of all modifiable parameters" \
                        $formatted_parameters
# NOTE: 
# Check if MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH contains the substring "invert"
if [[ ! "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}" == *"invert"* ]]; then
    # Remove lines from the copied input file
    sed -i '/^# For "invert" main progs/d' \
                        "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
    # Remove the line starting with "BINARY_SOLUTION_FILES_DIRECTORY="
    # and the following empty line
    sed -i '/^BINARY_SOLUTION_FILES_DIRECTORY=/{
        N
        /^.*\n$/d
    }' "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
fi
log "INFO" "'$ORIGINAL_FILE' text file was copied successfully."

# 3. Empty parameters file renamed "_params.ini_"
ORIGINAL_FILE="_params.ini_"
# Initialize empty_parameters_file_path variable
empty_parameters_file_path="./parameters_files/"
ERROR_MESSAGE="Corresponding empty parameters file cannot be located."
# The appropriate file to be copied needs to be selected 
# Check if destination path contains "invert"
if [[ "$MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH" == *"invert"* ]]; then
    # Destination path contains "invert"
    if [[ "$MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH" == *"overlap-kl"* ]]; then
        # Destination path contains "overlap-kl"
        empty_parameters_file_path+="KL_invert_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE \
                        "${SCRIPT_TERMINATION_MESSAGE}"
        cp ${empty_parameters_file_path} \
                        "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
        copy_exit_status=$?  # Store the exit status of the copy command
    elif [[ "$MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH" == *"overlap-Chebyshev"* ]];
        then
        # Destination path contains "overlap-Chebyshev"
        empty_parameters_file_path+="Chebyshev_invert_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE \
                        "${SCRIPT_TERMINATION_MESSAGE}"
        cp ${empty_parameters_file_path} \
                        "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
        copy_exit_status=$?  # Store the exit status of the copy command
    else
        # Destination path does not contain neither "overlap-kl" 
        # or "overlap-Chebyshev"
        empty_parameters_file_path+="Bare_invert_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE \
                        "${SCRIPT_TERMINATION_MESSAGE}"
        cp ${empty_parameters_file_path} \
                        "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
        copy_exit_status=$?  # Store the exit status of the copy command
    fi
else
    # Destination path does not contain "invert"
    if [[ "$MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH" == *"overlap-kl"* ]]; then
        # Destination path contains "overlap-kl"
        empty_parameters_file_path+="KL_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE \
                        "${SCRIPT_TERMINATION_MESSAGE}"
        cp ${empty_parameters_file_path} \
                        "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
        copy_exit_status=$?  # Store the exit status of the copy command
    elif [[ "$MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH" == *"overlap-Chebyshev"* ]];
        then
        # Destination path contains "overlap-Chebyshev"
        empty_parameters_file_path+="Chebyshev_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE \
                        "${SCRIPT_TERMINATION_MESSAGE}"
        cp ${empty_parameters_file_path} \
                        "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
        copy_exit_status=$?  # Store the exit status of the copy command
    else
        # Destination path does not contain neither "overlap-kl" 
        # or "overlap-Chebyshev"
        empty_parameters_file_path+="Bare_empty_parameters_file.ini"
        check_if_file_exists $empty_parameters_file_path $ERROR_MESSAGE \
                        "${SCRIPT_TERMINATION_MESSAGE}"
        cp ${empty_parameters_file_path} \
                        "${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}/$ORIGINAL_FILE"
        copy_exit_status=$?  # Store the exit status of the copy command
    fi
fi
if [ $copy_exit_status -ne 0 ]; then
    ERROR_MESSAGE="Copying '$ORIGINAL_FILE' file failed."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
# NOTE: Line "EMPTY_PARAMETERS_FILE_FULL_PATH=" of original "input.txt" is set 
# by default to "./_params.ini_". Update if "_params.ini_" is moved.
log "INFO" "Empty parameters file '$ORIGINAL_FILE' was copied successfully."

# 4. "update.sh" script
ORIGINAL_FILE=update.sh
check_if_file_exists $ORIGINAL_FILE \
                        "Original $ORIGINAL_FILE file cannot be located." \
                        "${SCRIPT_TERMINATION_MESSAGE}"
# NOTE: Line MAIN_SCRIPTS_DIRECTORY=... of the original file is auto-filled
sed -i \
    "s|^\(MAIN_SCRIPTS_DIRECTORY=\).*|\1\"$MAIN_SCRIPTS_DIRECTORY_FULL_PATH\"|"\
        "$ORIGINAL_FILE"
cp $ORIGINAL_FILE $MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH
if [ $? -ne 0 ]; then
    ERROR_MESSAGE="Copying '$ORIGINAL_FILE' file failed."
    termination_output "${ERROR_MESSAGE}" "${SCRIPT_TERMINATION_MESSAGE}"
    echo "Exiting..."
    exit 1
fi
copied_update_script_full_path=${MULTIPLE_RUNS_SCRIPTS_DIRECTORY_PATH}\
"/$ORIGINAL_FILE"
# NOTE: A warning is appended to the copied "update.sh" read-only script
insert_message $copied_update_script_full_path $target_line $WARNING_MESSAGE
# Make copied "update.sh" script an executable
chmod +x $copied_update_script_full_path
log "INFO" "'$ORIGINAL_FILE' script was copied successfully."

log "INFO" "All 4 files were copied successfully!"

# Remove ".sh" extension and capitalize the first letter of the script name
script_name=$(echo "${CURRENT_SCRIPT_NAME%.sh}" \
| awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
# Construct the final message
final_message="${script_name} process complete!"
# Print the final message
echo "$final_message"

log "INFO" "${final_message}"

echo -e $SCRIPT_TERMINATION_MESSAGE >> "$LOG_FILE_PATH"

#!/bin/sh -l

#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Source function definition files.
#
#-----------------------------------------------------------------------
#
cd ../ush
. ./source_funcs.sh
cd_vrfy -
#
#-----------------------------------------------------------------------
#
# Source the setup script.  Note that this in turn sources the configu-
# ration file/script (config.sh) in the current directory.  It also cre-
# ates the run and work directories, the INPUT and RESTART subdirecto-
# ries under the run directory, and a variable definitions file/script
# in the run directory.  The latter gets sources by each of the scripts
# that run the various workflow tasks.
#
#-----------------------------------------------------------------------
#
. ./setup.sh
#
#-----------------------------------------------------------------------
#
# Source function definition files.
#
#-----------------------------------------------------------------------
#
#cd ../ush
#. ./source_funcs.sh
#cd_vrfy -
#
#-----------------------------------------------------------------------
#
# Set the full paths to the template and actual workflow xml files.  The
# actual workflow xml will be placed in the run directory and then used
# by rocoto to run the workflow.
#
#-----------------------------------------------------------------------
#
TEMPLATE_XML_FP="$TEMPLATE_DIR/$WFLOW_XML_FN"
WFLOW_XML_FP="$EXPTDIR/$WFLOW_XML_FN"
#
#-----------------------------------------------------------------------
#
# Copy the xml template file to the run directory.
#
#-----------------------------------------------------------------------
#
cp_vrfy $TEMPLATE_XML_FP $WFLOW_XML_FP
#
#-----------------------------------------------------------------------
#
# Set local variables that will be used later below to replace place-
# holder values in the workflow xml file.
#
#-----------------------------------------------------------------------
#
PROC_RUN_FV3SAR="${NUM_NODES}:ppn=${ncores_per_node}"

FHR=( $( seq 0 1 $fcst_len_hrs ) )
i=0
FHR_STR=$( printf "%02d" "${FHR[i]}" )
numel=${#FHR[@]}
for i in $(seq 1 $(($numel-1)) ); do
  hour=$( printf "%02d" "${FHR[i]}" )
  FHR_STR="$FHR_STR $hour"
done
FHR="$FHR_STR"
#
#-----------------------------------------------------------------------
#
# Fill in the xml file with parameter values that are either specified
# in the configuration file/script (config.sh) or set in the setup
# script sourced above.
#
#-----------------------------------------------------------------------
#
set_file_param "$WFLOW_XML_FP" "SCRIPT_VAR_DEFNS_FP" "$SCRIPT_VAR_DEFNS_FP"
set_file_param "$WFLOW_XML_FP" "ACCOUNT" "$ACCOUNT"
set_file_param "$WFLOW_XML_FP" "SCHED" "$SCHED"
set_file_param "$WFLOW_XML_FP" "QUEUE_DEFAULT" "$QUEUE_DEFAULT"
set_file_param "$WFLOW_XML_FP" "QUEUE_HPSS" "$QUEUE_HPSS"
set_file_param "$WFLOW_XML_FP" "QUEUE_RUN_FV3SAR" "$QUEUE_RUN_FV3SAR"
set_file_param "$WFLOW_XML_FP" "USHDIR" "$USHDIR"
set_file_param "$WFLOW_XML_FP" "EXPTDIR" "$EXPTDIR"
set_file_param "$WFLOW_XML_FP" "EXTRN_MDL_NAME_ICSSURF" "$EXTRN_MDL_NAME_ICSSURF"
set_file_param "$WFLOW_XML_FP" "EXTRN_MDL_NAME_LBCS" "$EXTRN_MDL_NAME_LBCS"
set_file_param "$WFLOW_XML_FP" "EXTRN_MDL_FILES_SYSBASEDIR_ICSSURF" "$EXTRN_MDL_FILES_SYSBASEDIR_ICSSURF"
set_file_param "$WFLOW_XML_FP" "EXTRN_MDL_FILES_SYSBASEDIR_LBCS" "$EXTRN_MDL_FILES_SYSBASEDIR_LBCS"
set_file_param "$WFLOW_XML_FP" "PROC_RUN_FV3SAR" "$PROC_RUN_FV3SAR"
#set_file_param "$WFLOW_XML_FP" "DATE_FIRST_CYCL" "$DATE_FIRST_CYCL"
#set_file_param "$WFLOW_XML_FP" "DATE_LAST_CYCL" "$DATE_LAST_CYCL"
set_file_param "$WFLOW_XML_FP" "YYYY_FIRST_CYCL" "$YYYY_FIRST_CYCL"
set_file_param "$WFLOW_XML_FP" "MM_FIRST_CYCL" "$MM_FIRST_CYCL"
set_file_param "$WFLOW_XML_FP" "DD_FIRST_CYCL" "$DD_FIRST_CYCL"
set_file_param "$WFLOW_XML_FP" "HH_FIRST_CYCL" "$HH_FIRST_CYCL"
set_file_param "$WFLOW_XML_FP" "CDATE_FIRST_CYCL" "$CDATE_FIRST_CYCL"
set_file_param "$WFLOW_XML_FP" "CDATE_LAST_CYCL" "$CDATE_LAST_CYCL"
set_file_param "$WFLOW_XML_FP" "CYCL_INTVL" "$CYCL_INTVL"
set_file_param "$WFLOW_XML_FP" "FHR" "$FHR"


set_file_param "$WFLOW_XML_FP" "USER" "$username"
set_file_param "$WFLOW_XML_FP" "DOMAIN" "$dom"
set_file_param "$WFLOW_XML_FP" "SH" "$sh"
set_file_param "$WFLOW_XML_FP" "EH" "$eh"
set_file_param "$WFLOW_XML_FP" "BCNODES" "$bcnodes"
set_file_param "$WFLOW_XML_FP" "FCSTNODES" "$fcstnodes"
set_file_param "$WFLOW_XML_FP" "POSTNODES" "$postnodes"
set_file_param "$WFLOW_XML_FP" "GOESPOSTNODES" "$goespostthrottle"
set_file_param "$WFLOW_XML_FP" "GOESPOSTTHROTTLE" "$goespostthrottle"

#cat drive_fv3sar_template.xml \
#    | sed s:_USER_:${username}:g \
#    | sed s:_DOMAIN_:${dom}:g \
#    | sed s:_SH_:${sh}:g \
#    | sed s:_EH_:${eh}:g \
#    | sed s:_BCNODES_:${bcnodes}:g \
#    | sed s:_FCSTNODES_:${fcstnodes}:g \
#    | sed s:_POSTNODES_:${postnodes}:g \
#    | sed s:_GOESPOSTNODES_:${goespostnodes}:g \
#    | sed s:_GOESPOSTTHROTTLE_:${goespostthrottle}:g  > drive_fv3sar_${dom}.xml
#
#
#cat ../parm/input_sar.nml_template \
#    | sed s:_TASK_X_:${task_layout_x}:g \
#    | sed s:_TASK_Y_:${task_layout_y}:g \
#    | sed s:_NX_:${npx}:g \
#    | sed s:_NY_:${npy}:g \
#    | sed s:_TARG_LAT_:${target_lat}:g \
#    | sed s:_TARG_LON_:${target_lon}:g  > ../parm/input_sar_${dom}.nml
#   
#
#cat ../parm/model_configure_sar.tmp_template \
#    | sed s:_WG_:${write_groups}:g \
#    | sed s:_WTPG_:${write_tasks_per_group}:g \
#    | sed s:_CEN_LAT_:${cen_lat}:g \
#    | sed s:_CEN_LON_:${cen_lon}:g \
#    | sed s:_LON1_:${lon1}:g \
#    | sed s:_LAT1_:${lat1}:g \
#    | sed s:_LON2_:${lon2}:g \
#    | sed s:_LAT2_:${lat2}:g \
#    | sed s:_DLON_:${dlon}:g \
#    | sed s:_DLAT_:${dlat}:g  > ../parm/model_configure_sar.tmp_${dom}

#
#-----------------------------------------------------------------------
#
# Extract from CDATE the starting year, month, day, and hour of the
# forecast.  These are needed below for various operations.
#
#-----------------------------------------------------------------------
#
YYYY_FIRST_CYCL=${CDATE_FIRST_CYCL:0:4}
MM_FIRST_CYCL=${CDATE_FIRST_CYCL:4:2}
DD_FIRST_CYCL=${CDATE_FIRST_CYCL:6:2}
HH_FIRST_CYCL=${CDATE_FIRST_CYCL:8:2}
#HH_FIRST_CYCL=${CYCL_HRS[0]}
#
#-----------------------------------------------------------------------
#
# Replace the dummy line in the XML defining a generic cycle hour with
# one line per cycle hour containing actual values.
#
#-----------------------------------------------------------------------
#
#regex_search="(^\s*<cycledef\s+group=\"at_)(CC)(Z\">)(\&DATE_FIRST_CYCL;)(CC00)(\s+)(\&DATE_LAST_CYCL;)(CC00)(.*</cycledef>)(.*)"
#i=0
#for cycl in "${CYCL_HRS[@]}"; do
#  regex_replace="\1${cycl}\3\4${cycl}00 \7${cycl}00\9"
#  crnt_line=$( sed -n -r -e "s%$regex_search%$regex_replace%p" "$WFLOW_XML_FP" )
#  if [ "$i" -eq "0" ]; then
#    all_cycledefs="${crnt_line}"
#  else
#    all_cycledefs=$( printf "%s\n%s" "${all_cycledefs}" "${crnt_line}" )
#  fi
#  i=$(( $i+1 ))
#done
##
## Replace all actual newlines in the variable all_cycledefs with back-
## slash-n's.  This is needed in order for the sed command below to work
## properly (i.e. to avoid it failing with an "unterminated `s' command"
## message).
##
#all_cycledefs=${all_cycledefs//$'\n'/\\n}
##
## Replace all ampersands in the variable all_cycledefs with backslash-
## ampersands.  This is needed because the ampersand has a special mean-
## ing when it appears in the replacement string (here named regex_re-
## place) and thus must be escaped.
##
#all_cycledefs=${all_cycledefs//&/\\\&}
##
## Perform the subsutitution.
##
#sed -i -r -e "s|${regex_search}|${all_cycledefs}|g" "$WFLOW_XML_FP"
#
#-----------------------------------------------------------------------
#
# Save the current shell options, turn off the xtrace option, load the
# rocoto module, then restore the original shell options.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set +x; } > /dev/null 2>&1
module load rocoto/1.3.0
{ restore_shell_opts; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# For convenience, print out the commands that needs to be issued on the 
# command line in order to launch the workflow and to check its status.  
# Also, print out the command that should be placed in the user's cron-
# tab in order for the workflow to be continually resubmitted.
#
#-----------------------------------------------------------------------
#
WFLOW_DB_FN="${WFLOW_XML_FN%.xml}.db"
load_rocoto_cmd="module load rocoto/1.3.0"
rocotorun_cmd="rocotorun -w ${WFLOW_XML_FN} -d ${WFLOW_DB_FN} -v 10"
rocotostat_cmd="rocotostat -w ${WFLOW_XML_FN} -d ${WFLOW_DB_FN} -v 10"

print_info_msg "\
========================================================================
========================================================================

Workflow generation completed.

========================================================================
========================================================================

The experiment and work directories for this experiment configuration 
are:

  > EXPTDIR=\"$EXPTDIR\"
  > WORKDIR=\"$WORKDIR\"

To launch the workflow, first ensure that you have a compatible version
of rocoto loaded.  For example, on theia, the following version has been
tested and works:

  > $load_rocoto_cmd

(Later versions may also work but have not been tested.)  To launch the 
workflow, change location to the experiment directory (EXPTDIR) and is-
sue the rocotrun command, as follows:

  > cd $EXPTDIR
  > $rocotorun_cmd

To check on the status of the workflow, issue the rocotostat command 
(also from the experiment directory):

  > $rocotostat_cmd

Note that:

1) The rocotorun command must be issued after the completion of each 
   task in the workflow in order for the workflow to submit the next 
   task(s) to the queue.

2) In order for the output of the rocotostat command to be up-to-date,
   the rocotorun command must be issued immediately before the rocoto-
   stat command.

For automatic resubmission of the workflow (say every 3 minutes), the 
following line can be added to the user's crontab (use \"crontab -e\" to
edit the cron table): 

*/3 * * * * cd $EXPTDIR && $rocotorun_cmd

Done."
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1




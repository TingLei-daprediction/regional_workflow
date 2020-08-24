#!/bin/sh
############################################################################
# Script name:		run_regional_gfdlmp.sh
# Script description:	Run the 3-km FV3 regional forecast over the CONUS
#			using the GFDL microphysics scheme.
# Script history log:
#   1) 2018-03-14	Eric Rogers
#			run_nest.tmp retrieved from Eric's run_it directory.	
#   2) 2018-04-03	Ben Blake
#                       Modified from Eric's run_nest.tmp script.
#   3) 2018-04-13	Ben Blake
#			Various settings moved to JFV3_FORECAST J-job
#   4) 2018-06-19       Ben Blake
#                       Adapted for stand-alone regional configuration
############################################################################
set -eux

ulimit -s unlimited
ulimit -a
FORECASTSH=${FORECASTSH:-$HOMEfv3/scripts/dev-exfv3cam_sar_fcst.sh}
# Enemble group, begin and end
ENSGRP=${ENSGRP:-1}
ENSBEG=${ENSBEG:-1}
ENSEND=${ENSEND:-2}

################################################################################
# Run forecast for ensemble member
   export DATATOP=${DATATOP:-${STMP}/tmpnwprd-${CDATE}/${envir}/${job}_${cyc}_efcst}
export EnsAnMeanDir=$NWGES_ens/enkf_AnMean${tmmark}/ensmean
rc=0
for imem in $(seq $ENSBEG $ENSEND); do

   echo "begin forecast for member ",$imem



   cmem=$(printf %03i $imem)
   if [ $imem -eq 0 ] ; then
   memchar=ensmean
#use the lbc from the control runs
       if [ $tmmark = tm12 ] ; then
          export ensmemINPdir=${ensmemINPdir:-${COMOUT}/gfsanl.${tmmark}}
          else
          export ensmemINPdir=${ensmemINPdir:-${COMOUT}/anl.${tmmark}}
       fi
   else
   memchar="mem$cmem"
   export ensmemINPdir=${ensINPdir}/${memchar} 
   fi
  
   echo "Processing MEMBER: $cmem"
   if [ $tmmark = tm12 ] ; then 
   export FcstInDir=$ensmemINPdir
   else
   export EnsRecDir=$NWGES_ens/enkf_rec${tmmark}/$memchar
   if [ $imem -eq 0 ] ; then
   export FcstInDir=$EnsAnMeanDir
   else
   export FcstInDir=$EnsRecDir
     if [ ${l_use_other_ctrlb_opt:-.false.} = .false. ] ; then
      cp $ensmemINPdir/*bndy*nc $FcstInDir
     fi
   fi
   fi
   export FcstOutDir=$NWGES_ens/${tmmark_next}/$memchar
   mkdir -p $FcstOutDir
   export DATA=$DATATOP/$memchar
   rm -fr $DATA
   mkdir -p $DATA
   cd $DATA

   ra=0

   skip_mem="NO"
#clt   if [ -f ${EFCSGRP}.fail ]; then
#clt      memstat=$(cat ${EFCSGRP}.fail | grep "MEMBER $cmem" | grep "PASS" | wc -l)
#clt      [[ $memstat -eq 1 ]] && skip_mem="YES"
#clt   fi

   if [ $skip_mem = "NO" ]; then

      ra=0

      export MEMBER=$imem
      $FORECASTSH
      ra=$?

      # Notify a member forecast failed, freeze epos, but continue on to next member
      if [ $ra -ne 0 ]; then
#cltthinkdeb         msg="forecast of member $cmem FAILED"
#cltthinkdeb         print $msg
#cltthinkdeb         [[ $SENDECF = "YES" ]] && ecflow_client --abort=$msg
       echo "tothink to be finished "
      fi
      echo "shell is "$SHELL 
      echo  "thinkdeb -0"
#clttothink      (( rc += ra ))
      echo  "thinkdeb 0"
   fi
  echo "go to forecast for next member ,current imemi is " $imem
done





exit  0

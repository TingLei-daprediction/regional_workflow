#!/bin/bash -l
set -x


module load  rocoto/1.3.1
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t   post06_firstguess 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t forecast_firstguess  
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -m forecast_ens_tm06
#rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -m forecast_ens_tm06
exit
exit
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t   recenter_tm06 
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t   recenter_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t   enkf_eupd_tm06 
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -m post_forecast_firstguess 
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t forecast_ens_firstguess_grp01  
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t chgres_fcstbndy_tm06  
exit
rocotostat -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c all


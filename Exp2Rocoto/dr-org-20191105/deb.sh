#!/bin/bash -l
set -x


module load  rocoto/1.3.1
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t forecast_firstguess 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t forecast_ens_firstguess_grp01
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -m chgres_ens_firstguess 
exit
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -m forecast_ens_firstguess 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t chgres_firstguess 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -m chgres_ens_fcstbndy_da 
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t chgres_ens_tm12_grp01 
exit
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t chgres_ens01_fcstbndy_tm06
exit
exit
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dd.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910300000 -t chgres_fcstbndy_tm06 
exit
exit
exit
exit
exit
exit
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dd.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910300000 -t chgres_fcstbndy_tm06 
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t  chgres_fcstbndy_tm12 
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t recenter_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t enkf_eupd_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t enkf_obs_tm06_grp01 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t  emean_obs_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t epost2mean_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t analysis_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t forecast_ens_firstguess_grp01 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t chgres_ens01_fcstbndy_tm06
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201910030000 -t chgres_ens_tm12_grp01
exit
rocotorun -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db


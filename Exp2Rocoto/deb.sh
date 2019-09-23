#!/bin/bash -l
set +x
. /usrx/local/prod/lmod/lmod/init/sh
set -x

module load impi/18.0.1
module load lsf/10.1

module use /gpfs/dell3/usrx/local/dev/emc_rocoto/modulefiles/
module load ruby/2.5.1 rocoto/1.2.4
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -m enkf_obs_tm06 
exit
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t emean_obs_tm06 
exit
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t epost2mean_tm06 
exit
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t analysis_tm06 
exit
exit
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t recenter_tm06 
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t enkf_eupd_tm06 
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t enkf_obs_tm06_grp01 
rocotorewind -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t epost2mean_tm06 
exit
exit
exit
exit
rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t chgres_ens01_fcstbndy_tm06 
exit

rocotoboot -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/dr-regional-workflow/regional_workflow/Exp2Rocoto/dev.db -c 201909200000 -t chgres_ens_tm12_grp01


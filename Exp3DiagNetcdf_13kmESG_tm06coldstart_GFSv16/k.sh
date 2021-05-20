#!/bin/bash -l
set -x
#module load rocoto/1.2.4
module load rocoto/1.3.2


rundir=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-regional-workflow/regional_workflow/Exp2Rocoto_13kmESG_tm06coldstart_GFSv16
rocotostat -v 10 -w $rundir/k.xml -d $rundir/dev.db -t enkf_eupd_tm05  -c 202105060000
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -m enkf_obs_tm05  -c 202105060000
exit
rocotostat -v 10 -w $rundir/k.xml -d $rundir/dev.db   -c all
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t forecast_ens_tm06_ensgrp01  -c 202105060000
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -m chgres_ens_fcstbndy_da  -c 202105060000
exit
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t forecast_tm06  -c 202105060000
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t analysis_tm06  -c 202105060000
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t chgres_firstguess  -c 202105060000
exit
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t chgres_firstguess  -c 202105060000
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t forecast_firstguess  -c 202105060000
exit
exit
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -m forecast_ens_firstguess  -c 202105060000
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -m chgres_ens_firstguess  -c 202105060000
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t chgres_fcstbndy_tm12  -c 202105060000
exit
rocotoboot -v 10 -w $rundir/k.xml -d $rundir/dev.db -t chgres_ens_tm12_grp01  -c 202105060000
exit
exit
exit
exit
exit
exit
exit

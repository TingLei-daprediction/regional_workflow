#!/bin/bash -l
set -x
#module load rocoto/1.2.4
module load rocoto/1.3.2


rundir=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-regional-workflow/regional_workflow/Exp2Rocoto_13kmESG
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t forecast_tm00 
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t analysis_tm06
exit
exit
rocotostat  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c all
exit
rocotorewind  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -m forecast_ens_tm06
exit
rocotostat  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c all
exit
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t enkf_eupd_tm06
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t chgres_fcstbndy_tm00
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -m enkf_obs_tm06 
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t emean_obs_tm06
exit
exit
exit
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t forecast_ens_tm06_ensgrp01 
exit
exit
exit
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -m enkf_obs_tm06 
exit
exit
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -m EnKF_analysis_tm06
exit
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t chgres_ens_tm12_grp01
exit
rocotorewind  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t forecast_firstguess
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t chgres_ens_tm12_grp01
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t analysis_tm06
exit
exit
rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t chgres_fcstbndy_tm12 

rocotoboot  -v 10 -w $rundir/deb.xml -d $rundir/deb.db -c 202102180000 -t chgres_firstguess

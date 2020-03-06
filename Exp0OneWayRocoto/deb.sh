#!/bin/bash -l
set -x


module load  rocoto/1.3.
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -m post_tm00 
exit
rocotostat -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c all 
exit
exit
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t forecast_tm06 
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t forecast_tm06 
exit
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t analysis_tm06 
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t analysis_tm06 
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t analysis_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -m post_tm06-01 
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t forecast_tm00 
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t forecast_tm01 
exit
exit
exit
exit
exit
exit
exit
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t forecast_tm06 
exit
exit
exit
exit
exit
exit
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t analysis_tm00 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t chgres_fcstbndy_tm00 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t analysis_tm05 
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db -c 201912281200 -t forecast_tm06 
exit
exit
exit
rocotorun -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0OneWayRocoto/dev-1way.db


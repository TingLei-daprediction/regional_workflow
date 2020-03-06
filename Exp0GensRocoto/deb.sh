#!/bin/bash -l
set -x
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -m  post_tm00 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t forecast_tm00 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t analysis_tm00 
exit
exit

exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -m post_forecast_firstguess 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -m  post_tm06-01 
exit
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t forecast_firstguess 
exit
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t forecast_firstguess 
exit

module load  rocoto/1.3.
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -m post_tm00 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t forecast_tm01 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t analysis_tm01 
exit
exit
exit
exit
exit
exit
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t forecast_tm05 
exit
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -m post_tm06-01 
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t analysis_tm06 
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -m chgres_fcstbndy_da 
exit
exit
rocotostat -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c all 
exit
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t forecast_tm00 
exit
exit
rocotorewind -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t chgres_fcstbndy_tm00 
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db -c 201912281200 -t chgres_fcstbndy_tm00 
exit
exit
rocotorun -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0GensRocoto/dev-Gens.db


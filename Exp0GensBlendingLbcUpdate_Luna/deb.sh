#!/bin/bash -l
set -x
module load xt-lsfhpc/9.1.3
module load NetCDF-intel-haswell/4.2
module use -a /usrx/local/emc_rocoto/modulefiles
#module load rocoto/1.2.4
module load rocoto/1.3.0rc2
rocotoboot -v 10 -w /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.xml -d /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.db -c 202005040000 -t analysis_tm06 
exit
rocotoboot -v 10 -w /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.xml -d /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.db -c 202005040000 -t forecast_tm06 
exit
rocotoboot -v 10 -w /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.xml -d /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.db -c 202005040000 -t analysis_tm06 

exit

rocotorewind -v 10 -w /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.xml -d /gpfs/hps3/emc/meso/save/Ting.Lei/dr-regional-workflow/regional_workflow/Exp0GensRocoto_surge/dev-Gens.db -c 202005040000 -t forecast_firstguess


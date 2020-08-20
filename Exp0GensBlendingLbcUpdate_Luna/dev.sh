#!/bin/bash -l
set -x
module load xt-lsfhpc/9.1.3
module load NetCDF-intel-haswell/4.2
module use -a /usrx/local/emc_rocoto/modulefiles
#module load rocoto/1.2.4
module load rocoto/1.3.0rc2



rocotorun -v 10 -w /gpfs/hps3/emc/meso/save/Ting.Lei/dr-new-regional-workflow/regional_workflow/Exp0GensBlendingLbcUpdate_Luna/dev-Gens.xml -d /gpfs/hps3/emc/meso/save/Ting.Lei/dr-new-regional-workflow/regional_workflow/Exp0GensBlendingLbcUpdate_Luna/dev-Gens.db

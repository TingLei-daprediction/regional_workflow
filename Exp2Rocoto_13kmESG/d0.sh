#! /bin/sh
#SBATCH --account=fv3-cam
#SBATCH --qos=batch
#SBATCH --partition=hera
#SBATCH --ntasks=170
#SBATCH -t 01:00:00
#SBATCH --job-name=run_fcst
#SBATCH -o /scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-unified-workflow/expt_dirs/test_CONUS_13kmESG_GFSv15p2/d0.log
#SBATCH --cpus-per-task 4 --exclusive
#SBATCH --comment=652e3f99cdf56861f1f1fa01269272d5


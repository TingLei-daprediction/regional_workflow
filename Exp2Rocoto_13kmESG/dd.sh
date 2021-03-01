#! /bin/sh
#SBATCH --job-name=forecast_firstguess_00
#SBATCH -o /scratch2/NCEPDEV/stmp3/Ting.Lei/logs/EXP2region_13kmESG/dr2021012900.log/forecast_firstguess_00.log
#SBATCH --qos=batch
#SBATCH --account=fv3-cam
#SBATCH --nodes=34
#SBATCH --tasks-per-node=5
#SBATCH -t 04:00:00
#SBATCH --comment=9cd082849cd1942cb4a0d65eed7ec29c


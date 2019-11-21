set -x

###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_gsianl.sh
# Script description:  Runs FV3SAR GSI analysis for the hourly DA cycle
#                      Uses RAP observations and Fv3GDAS EnKF files for the hybrid
#                      analysis. Create conventional and radiance stat files for monitoring
#
# Script history log:
# 2018-10-30  $USER - Modified based on original GSI script
#
export ldo_enscalc_option=${ldo_enscalc_option:-1}
machine=DELL


offset=`echo $tmmark | cut -c 3-4`

case $tmmark in
  tm06) export tmmark_prev=tm06;;
  tm05) export tmmark_prev=tm06;;
  tm04) export tmmark_prev=tm05;;
  tm03) export tmmark_prev=tm04;;
  tm02) export tmmark_prev=tm03;;
  tm01) export tmmark_prev=tm02;;
  tm00) export tmmark_prev=tm01;;
esac

export vlddate=`$NDATE -${offset} $CYCLE`
export SDATE=$vlddate
export cyc=`echo $vlddate | cut -c 9-10`
export cya=`echo $vlddate | cut -c 9-10`
export CYC=`echo $vlddate | cut -c 9-10`
export PDY=`echo $vlddate | cut -c 1-8`
export PDYrun=`echo $CYCLE | cut -c 1-8`
export PDYa=`echo $vlddate | cut -c 1-8`
export CYCrun=`echo $CYCLE | cut -c 9-10`

 export gsiexec=${gsiexec:-$gsiexec0}

# Set runtime and save directories
export endianness=Big_Endian

# Set variables used in script
#   ncp is cp replacement, currently keep as /bin/cp
export ncp=/bin/cp
export NLN=${NLN:-"/bin/ln -sf"}

# setup ensemble filelist03

#clt bob  from exglobal_innovate_obs_fv3gfs.sh.ecf
################################################################################
## ObsInput file from ensemble mean
rm -f obs_input*
export SELECT_OBS=${SELECT_OBS:-${COMOUT}/obsinput_${CDATE}_${tmmark}_ensmean}
$NLN $SELECT_OBS obs_input.tar
export USE_SELECT=YES
export RUN_SELECT=NO
if [ $RUN_SELECT = "YES" -a $USE_SELECT = "NO" ]; then
  export  lread_obs_save=".true."
  export  lread_obs_skip=".false."
elif [ $RUN_SELECT = "NO" -a $USE_SELECT = "YES" ]; then
  export  lread_obs_save=".false."
  export  lread_obs_skip=".true."
fi
export SETUP_part1="miter=0,niter=1"
export lread_obs_part="lread_obs_save=$lread_obs_save,lread_obs_skip=$lread_obs_skip,"
################################################################################
## Innovation Specific setup for ANALYSISSH
#export DIAG_SUFFIX=${DIAG_SUFFIX:-""}
#export DIAG_COMPRESS=${DIAG_COMPRESS:-"NO"}
#export DIAG_TARBALL=${DIAG_TARBALL:-"YES"}
#export DOHYBVAR="NO"
#export DO_CALC_INCREMENT="NO"
#






##clt eob

















export HYB_ENS=".true."

# We expect 81 total files to be present (80 enkf + 1 mean)
export nens=${nens:-20}

# Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
export nhr_assimilation=03

export DOHYBVAR=NO
export HX_ONLY=TRUE
#cltthinkdeb nens=`cat filelist03 | wc -l`

# Set parameters
################################################################################
## Innovation Specific setup for ANALYSISSH

## Innovation Specific setup for ANALYSISSH
export DIAG_SUFFIX=${DIAG_SUFFIX:-""}
export DIAG_COMPRESS=${DIAG_COMPRESS:-"NO"}
export DIAG_TARBALL=${DIAG_TARBALL:-"YES"}
export DOHYBVAR="NO"
export DO_CALC_INCREMENT="NO"
#
## GSI Namelist options for observation operator only

# Run gsi under Parallel Operating Environment (poe) on NCEP IBM
ENSGRP=${ENSGRP:-1}
ENSBEG=${ENSBEG:-1}
ENSEND=${ENSEND:-2}


for imem in $(seq $ENSBEG $ENSEND); do
export memstr=$(printf %03i $imem)
export ctrlstr=mem$memstr
ensfiletype=${enfiletype:-bg}
EnsMemDir=$NWGES_ens/${tmmark}/mem$memstr
export BgFile4dynvar=$EnsMemDir/${PDY}.${CYC}0000.fv_core.res.tile1.nc
export  BgFile4tracer=$EnsMemDir/${PDY}.${CYC}0000.fv_tracer.res.tile1.nc
 echo "Processing MEMBER:" $memstr 
export DATA=$DATATOP/$memstr
rm -fr $DATA
mkdir -p $DATA
cd $DATA
anavinfo=$PARMfv3/anavinfo_fv3_enkf_64
cp $anavinfo ./anavinfo
$gsianlsh
done

export ERR=$rc
export err=$ERR
# Cat runtime output files.

exit

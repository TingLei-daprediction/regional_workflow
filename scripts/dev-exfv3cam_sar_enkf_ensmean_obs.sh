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
ncp=/bin/cp

#clt bob  from exglobal_innovate_obs_fv3gfs.sh.ecf
################################################################################
## ObsInput file from ensemble mean
rm -f obs_input*
export SELECT_OBS=${SELECT_OBS:-${COMOUT}/obsinput_${CDATE}_${tmmark}_ensmean}
rm -fr $SELECT_OBS
export USE_SELECT=NO
export RUN_SELECT=YES
if [ $RUN_SELECT = "YES" -a $USE_SELECT = "NO" ]; then
   lread_obs_save=".true."
   lread_obs_skip=".false."
elif [ $RUN_SELECT = "NO" -a $USE_SELECT = "YES" ]; then
   lread_obs_save=".false."
   lread_obs_skip=".true."
fi
export lread_obs_part="lread_obs_save=$lread_obs_save,lread_obs_skip=$lread_obs_skip=,"
export SETUP_part1="miter=0,niter=1"

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
##typeset -Z2 nhr_assimilation

#module switch python/2.7.14
#python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=no --minsize=${nens} -d ${COMINgfspll}/enkfgdas -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes
####python $UTIL/getbest_EnKF.py -v $vlddate --exact=no --minsize=${nens} -d ${COMINgfs}/enkf -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes

#Check to see if ensembles were found 
#numfiles=`cat filelist03 | wc -l`
#cp filelist03 $COMOUT/${RUN}.t${CYCrun}z.filelist03.${tmmark}



export DOHYBVAR=NO
export HX_ONLY=TRUE
#cltthinkdeb nens=`cat filelist03 | wc -l`
anavinfo=$PARMfv3/anavinfo_fv3_enkf_64
cp $anavinfo ./anavinfo

# Set parameters
################################################################################
## Innovation Specific setup for ANALYSISSH
export DIAG_SUFFIX=${DIAG_SUFFIX:-""}
export DIAG_COMPRESS=${DIAG_COMPRESS:-"NO"}
export DIAG_TARBALL=${DIAG_TARBALL:-"YES"}
export DOHYBVAR="NO"
export DO_CALC_INCREMENT="NO"
#
## GSI Namelist options for observation operator only



#cltthink end



# Run gsi under Parallel Operating Environment (poe) on NCEP IBM

export ctrlstr="ensmean"
memstr="ensmean"
ensfiletype=${enfiletype:-bg}
EnsMeanDir=$NWGES_ens/enkf_mean${tmmark}/$memstr
export BgFile4dynvar=$EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype}_${memstr}_fv_core.res.tile1.nc
export  BgFile4tracer=$EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype}_${memstr}_fv_tracer.res.tile1.nc

$gsianlsh

export ERR=$rc
export err=$ERR
# Cat runtime output files.

exit

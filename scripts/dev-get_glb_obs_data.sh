#!/bin/sh
############################################################################
# Script name:		exfv3cam_sar_chgres.sh
# Script description:	Makes ICs on fv3 stand-alone regional grid 
#                       using FV3GFS initial conditions.
# Script history log:
#   1) 2016-09-30       Fanglin Yang
#   2) 2017-02-08	Fanglin Yang and George Gayno
#			Use the new CHGRES George Gayno developed.
#   3) 2019-05-02	Ben Blake
#			Created exfv3cam_sar_chgres.sh script
#			from global_chgres_driver.sh
############################################################################
set -ax
export PDYrun=`echo $CDATE | cut -c 1-8`
GLB_OBS_DATA_TAR=${PDYrun}-rapobs.tar
rm -f $GLB_OBS_DATA_TAR
if [ 1 = 2 ]; then
nens=2
export vlddate=`$NDATE -${offset} $CDATE`
python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=yes --minsize=${nens} -d ${COMINgfs0}/enkfgdas -o filelist03 --o3fname=gfs_sigf${nhr_assimilation} --gfs_netcdf=yes

tar  uvf  $GLB_OBS_DATA_TAR -T filelist03 


# gtype = regional
echo "creating standalone regional BCs"
export ntiles=1
export TILE_NUM=7

export input_dir=$INIDIR
rm -f filelist.ges

$GETGES -t natges -v $CYCLEguess -e ${envir_getges} atmf00
$GETGES -t sfcges -v $CYCLEguess -e ${envir_getges} sfcf00

#

# These are set in ENVIR J-job
# NHRS = lentgh of free forecast
# NHRSda = length of DA cycle forecast (always 1-h)
# NHRSguess = length of DA cycle tm12 forecast (always 6-h)

if [ $tmmark = tm00 ]; then
  # if model=fv3sar_da, need to make 0-h BC file, otherwise it is made
  # in MAKE_IC job for fv3sar coldstart fcst off GFS anl
  if [ $model = fv3sar_da ] ; then
    hour=${HRBGN:-0}  #  0
  else
    hour=${HRBGN:-3} #  3
  fi
  end_hour=${HREND:-$NHRS}
  hour_inc=3
elif [ $tmmark = tm12 ] ; then
  hour=3
  end_hour=$NHRSguess
  hour_inc=3
else
  hour=0
  end_hour=6           #$NHRSda
  hour_inc=1
fi

while (test "$hour" -le "$end_hour")
  do
  if [ $hour -lt 10 ]; then
    hour_name='00'$hour
  elif [ $hour -lt 100 ]; then
    hour_name='0'$hour
  else
    hour_name=$hour
  fi

#  VDATE here needs to be valid date of GFS BC file
  if [ $tmmark = tm12 ] ; then
  export VDATE=`${NDATE} ${hour} ${CYCLEguess}`
  mmstart=`echo ${CYCLEguess} | cut -c 5-6`
  ddstart=`echo ${CYCLEguess} | cut -c 7-8`
  hhstart=`echo ${CYCLEguess} | cut -c 9-10`
  else
# CDATE comes from J-job
  export VDATE=`${NDATE} ${hour} ${CDATE}`
  mmstart=`echo ${CDATE} | cut -c 5-6`
  ddstart=`echo ${CDATE} | cut -c 7-8`
  hhstart=`echo ${CDATE} | cut -c 9-10`
  fi

# force tm00 to get ontime FV3GFS run
   $GETGES -t pg2cur -v $VDATE -e prod -c $COMINgfs0 atmf${hour_name}.pg2cura
   $GETGES -t pg2curb -v $VDATE -e prod atmf${hour_name}.pg2curb

    export PDYgfs=`echo $CDATE | cut -c 1-8`
    export CYCgfs=`echo $CDATE | cut -c 9-10`
   tar uvf $GLB_OBS_DATA_TAR  $COMINgfs0/gfs.${PDYgfs}/${CYCgfs}/atmos/gfs.t${CYCgfs}z.pgrb2.0p25.f${hour_name} #atmf${hour_name}.pg2cura
   tar uvf $GLB_OBS_DATA_TAR  $COMINgfs/gfs.${PDYgfs}/${CYCgfs}/atmos/gfs.t${CYCgfs}z.pgrb2b.0p25.f${hour_name} #atmf${hour_name}.pg2curb

  hour=`expr $hour + $hour_inc`
#
# move output files to save directory
#

done
fi 
 export PDYrun=`echo $CDATE | cut -c 1-8`
export nmmb_nems_obs=${COMINrap}/rap.${PDYrun}
tar  uvf  $GLB_OBS_DATA_TAR $nmmb_nems_obs/*bufr*  
mv $GLB_OBS_DATA_TAR  $COMINrap_user

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

# gtype = regional
echo "creating standalone regional BCs"
export ntiles=1
export TILE_NUM=7

if [ $tmmark = tm00 ] ; then
# input data is FV3GFS (ictype is 'pfv3gfs')
export ATMANL=$INIDIR/${CDUMP}.t${cyc}z.atmanl.nemsio
export SFCANL=$INIDIR/${CDUMP}.t${cyc}z.sfcanl.nemsio
atmfile=${CDUMP}.t${cyc}z.atmanl.nemsio
sfcfile=${CDUMP}.t${cyc}z.sfcanl.nemsio
export input_dir=$INIDIR
monthguess=`echo ${CDATE} | cut -c 5-6`
dayguess=`echo ${CDATE} | cut -c 7-8`
cycleguess=`echo ${CDATE} | cut -c 9-10`
fi
if [ $tmmark = tm12 ] ; then
# input data is FV3GFS (ictype is 'pfv3gfs')
# not needed in this job as tm12 IC/00-h BC made in make_ic job
##export ATMANL=$INIDIRtm12/${CDUMP}.t${cycguess}z.atmanl.nemsio
##export SFCANL=$INIDIRtm12/${CDUMP}.t${cycguess}z.sfcanl.nemsio
##export input_dir=$INIDIRtm12
##atmfile=${CDUMP}.t${cycguess}z.atmanl.nemsio
##sfcfile=${CDUMP}.t${cycguess}z.sfcanl.nemsio
monthguess=`echo ${CYCLEguess} | cut -c 5-6`
dayguess=`echo ${CYCLEguess} | cut -c 7-8`
fi

#
# set the links to use the 4 halo grid and orog files
# these are necessary for creating the boundary data
#
ln -sf $FIXsar/${CASE}_grid.tile7.halo4.nc $FIXsar/${CASE}_grid.tile7.nc 
ln -sf $FIXsar/${CASE}_oro_data.tile7.halo4.nc $FIXsar/${CASE}_oro_data.tile7.nc 
ln -sf $FIXsar/${CASE}.vegetation_greenness.tile7.halo4.nc $FIXsar/${CASE}.vegetation_greenness.tile7.nc
ln -sf $FIXsar/${CASE}.soil_type.tile7.halo4.nc $FIXsar/${CASE}.soil_type.tile7.nc
ln -sf $FIXsar/${CASE}.slope_type.tile7.halo4.nc $FIXsar/${CASE}.slope_type.tile7.nc
ln -sf $FIXsar/${CASE}.substrate_temperature.tile7.halo4.nc $FIXsar/${CASE}.substrate_temperature.tile7.nc
ln -sf $FIXsar/${CASE}.facsf.tile7.halo4.nc $FIXsar/${CASE}.facsf.tile7.nc
ln -sf $FIXsar/${CASE}.maximum_snow_albedo.tile7.halo4.nc $FIXsar/${CASE}.maximum_snow_albedo.tile7.nc
ln -sf $FIXsar/${CASE}.snowfree_albedo.tile7.halo4.nc $FIXsar/${CASE}.snowfree_albedo.tile7.nc
ln -sf $FIXsar/${CASE}.vegetation_type.tile7.halo4.nc $FIXsar/${CASE}.vegetation_type.tile7.nc

#
# create namelist and run chgres cube
#
cp ${CHGRESEXEC} .

# These are set in ENVIR J-job
# NHRS = lentgh of free forecast
# NHRSda = length of DA cycle forecast (always 1-h)
# NHRSguess = length of DA cycle tm12 forecast (always 6-h)

if [ $tmmark = tm00 ]; then
  # if model=fv3sar_da, need to make 0-h BC file, otherwise it is made
  # in MAKE_IC job for fv3sar coldstart fcst off GFS anl
  if [ $model = fv3sar_da ] ; then
    hour=0
  else
    hour=3
  fi
  end_hour=$NHRS
  hour_inc=3
elif [ $tmmark = tm12 ] ; then
  hour=3
  end_hour=$NHRSguess
  hour_inc=3
else
  hour=0
  end_hour=$NHRSda
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
  if [ $tmmark != tm00 ] ; then
    $GETGES -t natcur -v $VDATE -e prod atmf${hour_name}.nemsio
    atmfile=atmf${hour_name}.nemsio
  else
    export PDYgfs=`echo $CDATE | cut -c 1-8`
    export CYCgfs=`echo $CDATE | cut -c 9-10`
    if [ $hour_name -eq 000 ] ; then
      cp $COMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmanl.nemsio atmf${hour_name}.nemsio
    else
      cp $COMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmf${hour_name}.nemsio atmf${hour_name}.nemsio
    fi
    atmfile=atmf${hour_name}.nemsio
  fi

cat <<EOF >fort.41
&config
 mosaic_file_target_grid="$FIXsar/${CASE}_mosaic.nc"
 fix_dir_target_grid="$FIXsar"
 orog_dir_target_grid="$FIXsar"
 orog_files_target_grid="${CASE}_oro_data.tile7.halo4.nc"
 vcoord_file_target_grid="${FIXam}/global_hyblev.l${LEVS}.txt"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${DATA}"
 atm_files_input_grid="$atmfile"
 sfc_files_input_grid="NULL"
 cycle_mon=$mmstart
 cycle_day=$ddstart
 cycle_hour=$hhstart
 convert_atm=.true.
 convert_sfc=.false.
 convert_nst=.false.
 input_type="gaussian"
 tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
 tracers_input="spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"
 regional=${REGIONAL}
 halo_bndy=${HALO}
/
EOF

export pgm=regional_chgres_cube.x
. prep_step

  startmsg
  time ${APRUNC} -l ./regional_chgres_cube.x
  export err=$?
  ###export err=$?;err_chk

  if [ $err -ne 0 ] ; then
  exit 99
  fi

  hour=`expr $hour + $hour_inc`

#
# move output files to save directory
#
  mv gfs.bndy.nc $INPdir/gfs_bndy.tile7.${hour_name}.nc
  err=$?
  if [ $err -ne 0 ] ; then
    echo "Don't have ${hour_name}-h BC file at ${tmmark}, abort run"
    exit 99
  fi

done

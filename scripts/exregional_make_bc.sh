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

export input_dir=$INIDIR

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

export CHGRESVARS="use_ufo=.false.,nst_anl=$nst_anl,idvc=2,nvcoord=2,idvt=21,idsl=1,IDVM=0,nopdpvv=$nopdpvv"
# force tm00 to get ontime FV3GFS run
  if [ $tmmark != tm00  ] ; then #cltthinkdeb
   $GETGES -t pg2cur -v $VDATE -e prod -c $COMINgfs0 atmf${hour_name}.pg2cura
    $GETGES -t pg2curb -v $VDATE -e prod atmf${hour_name}.pg2curb
    cat atmf${hour_name}.pg2cura atmf${hour_name}.pg2curb > atmf${hour_name}.pg2comb
    rm atmf${hour_name}.pg2cura atmf${hour_name}.pg2curb
    echo "thinkdeb"
    wgrib2 atmf${hour_name}.pg2comb -submsg 1 | $UtilUshfv3/grib2_unique.pl | wgrib2 -i atmf${hour_name}.pg2comb -GRIB atmf${hour_name}.pg2cur

  else
    export PDYgfs=`echo $CDATE | cut -c 1-8`
    export CYCgfs=`echo $CDATE | cut -c 9-10`
   cp $COMINgfs0/gfs.${PDYgfs}/${CYCgfs}/atmos/gfs.t${CYCgfs}z.pgrb2.0p25.f${hour_name} atmf${hour_name}.pg2cura
cp $COMINgfs/gfs.${PDYgfs}/${CYCgfs}/atmos/gfs.t${CYCgfs}z.pgrb2b.0p25.f${hour_name} atmf${hour_name}.pg2curb

cat atmf${hour_name}.pg2cura atmf${hour_name}.pg2curb > atmf${hour_name}.pg2comb
rm atmf${hour_name}.pg2cura atmf${hour_name}.pg2curb

wgrib2 atmf${hour_name}.pg2comb -submsg 1 | $UtilUshfv3/grib2_unique.pl | wgrib2 -i atmf${hour_name}.pg2comb -GRIB atmf${hour_name}.pg2cur

  fi
atmfile=atmf${hour_name}.pg2cur

cat <<EOF >fort.41
&config
 mosaic_file_target_grid="$FIXsar/${CASE}_mosaic.halo${HALO}.nc"
 fix_dir_target_grid="$FIXsar"
 orog_dir_target_grid="$FIXsar"
 orog_files_target_grid="${CASE}_oro_data.tile7.halo4.nc"
 vcoord_file_target_grid="${PARMfv3}/global_hyblev.l${LEVS}.txt"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${DATA}"
 grib2_file_input_grid="$atmfile"
 varmap_file="$PARMfv3/GFSphys_var_map.txt"
 sfc_files_input_grid="NULL"
 cycle_mon=$mmstart
 cycle_day=$ddstart
 cycle_hour=$hhstart
 input_type="grib2"  
 convert_atm=.true.
 convert_sfc=.false.
 convert_nst=.false.
 regional=${REGIONAL}
 halo_bndy=${HALO}
 halo_blend=${NROWS_BLEND:-0}
/
EOF

export pgm=regional_chgres_cube.x

  time ${APRUNC}  ./regional_chgres_cube.x
  export err=$?
  ###export err=$?;err_chk

  if [ $err -ne 0 ] ; then
  exit 99
  fi

  hour=`expr $hour + $hour_inc`
#
# move output files to save directory
#
  mv gfs?bndy.nc $INPdir/gfs_bndy.tile7.${hour_name}.nc
  err=$?
  if [ $err -ne 0 ] ; then
    echo "Don't have ${hour_name}-h BC file at ${tmmark}, abort run"
    exit 99
  fi

done

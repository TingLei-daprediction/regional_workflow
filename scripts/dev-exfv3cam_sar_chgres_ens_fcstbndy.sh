#!/bin/ksh

################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_chgres_firstguess.sh
# Script description:  Gets best available FV3GFS atmf nemsio files to make FV3SAR IC's 
#                      and 3-h BC's for the 6-h forecast from T-12 h to generate the 
#                      first guess at T-6h for the FV3SAR hourly DA cycle
#
# Script history log:
# 2018-10-30  $USER - Modified based on original chgres job
#

set -x
export NODES=1
#
#
# the following exports can all be set or just will default to what is in global_chgres_driver.sh
#
export OMP_NUM_THREADS_CH=24       # default for openMP threads
export CASE=C768                   # resolution of tile: 48, 96, 192, 384, 768, 1152, 3072
export ymd=`echo $CDATE | cut -c 1-8`
export hhcyc=`echo $CDATE | cut -c 9-10`
###export LEVS=64
export LEVS=${LEVS:-61}
export LSOIL=4
export NTRAC=7
export ictype=pfv3gfs              # opsgfs for q3fy17 gfs with new land datasets; oldgfs for q2fy16 gfs.
export nst_anl=.false.             # false or true to include NST analysis



offset=`echo $tmmark | cut -c 3-4`

export vlddate=`$NDATE -${offset} $CYCLE`
export SDATE=$vlddate
export cyc=`echo $vlddate | cut -c 9-10`
export cya=`echo $vlddate | cut -c 9-10`
export CYC=`echo $vlddate | cut -c 9-10`
export PDY=`echo $vlddate | cut -c 1-8`
export PDYrun=`echo $CYCLE | cut -c 1-8`
export PDYa=`echo $vlddate | cut -c 1-8`
export CYCrun=`echo $CYCLE | cut -c 9-10`







#
#





export CDAS=gfs
CRES=`echo $CASE | cut -c 2-`

#

#clt for treatments of ensembles 
export DATAbase=$DATA
# Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
export nhr_assimilation=03
##typeset -Z2 nhr_assimilation
export nens=${nens:-20}
rm -f filelist${nhr_assimilation}_tmp_ens$ENSGRP 


if [ $gtype = regional ] ; then
 export REGIONAL=2
 export HALO=4
#
# set the links to use the 4 halo grid and orog files
# these are necessary for creating the boundary data
# no need to do this every time it runs!
#
#cltln -sf $FIXfv3/$CASE/${CASE}_grid.tile7.halo4.nc $FIXfv3/$CASE/${CASE}_grid.tile7.nc
#clt ln -sf $FIXfv3/$CASE/${CASE}_oro_data.tile7.halo4.nc $FIXfv3/$CASE/${CASE}_oro_data.tile7.nc
else
#
# for gtype = uniform, stretch or nest
#
 export REGIONAL=0
fi


#
#execute the chgres driver
#
export res=768            #-- FV3 equivalent to 13-km global resolution
export RES=C$res
export RUN=${RES}_nest_$CDATE

#INPdir is $COMOUT/gfsanl.tm12, set in J-job

#ctlorg mv $OUTDIR/gfs*nc $INPdir/.
#cltorg mv $OUTDIR/sfc*nc $INPdir/.
export REGIONAL=2
export CONVERT_SFC=.false.
unset ATMANL
unset SFCANL

#NHRSguess comes from JFV3SAR_ENVIR
hour=0
# NHRS = length of free forecast
# NHRSda = length of DA cycle forecast (always 1-h)
if [ $tmmark = tm00 ] ; then
  end_hour=$NHRS
  hour_inc=3
else
  end_hour=$NHRSda
  hour_inc=1
fi

while (test "$hour" -le "$end_hour")
 do
  if [ $hour -lt 10 ]; then
   export hour_name='00'$hour
  elif [ $hour -lt 100 ]; then
   export hour_name='0'$hour
  else
   export hour_name=$hour
  fi
offset=`echo $tmmark | cut -c 3-4`

export vlddate0=`$NDATE -${offset} $CYCLE`
export vlddate=`$NDATE +${hour} $vlddate0`
export SDATE=$vlddate
export cyc=`echo $vlddate | cut -c 9-10`
export cya=`echo $vlddate | cut -c 9-10`
export CYC=`echo $vlddate | cut -c 9-10`
export PDY=`echo $vlddate | cut -c 1-8`
export PDYrun=`echo $CYCLE | cut -c 1-8`
export PDYa=`echo $vlddate | cut -c 1-8`
export CYCrun=`echo $CYCLE | cut -c 9-10`
rm -f filelist${nhr_assimilation}_tmp0_ens$ENSGRP
python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=yes --minsize=${nens} -d ${COMINgfs}/enkfgdas -o filelist${nhr_assimilation}_tmp0_ens$ENSGRP --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes

sed '/ensmean/d'  filelist${nhr_assimilation}_tmp0_ens$ENSGRP> filelist${nhr_assimilation}_tmp_ens$ENSGRP 
cat  filelist${nhr_assimilation}_tmp_ens$ENSGRP 
#Check to see if ensembles were found 
numfiles=`cat  filelist${nhr_assimilation}_tmp_ens$ENSGRP | wc -l`
L_USE_CONTROL_LBC=.false.
if [ $numfiles -lt ${nens:-20} ]; then
  echo "Ensembles not found - turning off HYBENS!"
  export L_USE_CONTROL_LBC=".true."
fi

export bchour=$hour_name
if [ $L_USE_CONTROL_LBC != ".true." ]; then
ENSGRP=${ENSGRP:-1}
ENSBEG=${ENSBEG:-1}
ENSEND=${ENSEND:-2}

#cltthink nens=`cat filelist03 | wc -l`
cp filelist${nhr_assimilation}_tmp_ens$ENSGRP $COMOUT/${RUN}.t${CYCrun}z.ens_chgres_bndry_.vldatest${nhr_assimilation}_ens$ENSGRP-${vlddate}

#cltorg head -${nens} filelist03>filelist03_ensgrp$ENSGRP
 if [ $ENSGRP -eq 1 ]; then
    let "line1 = $ENSBEG  " 
    let "line2 = $ENSEND   " 
 else
    let "line1 = $ENSBEG   " 
    let "line2 = $ENSEND   " 
 fi
#head -${nens} filelist03>filelist03_ensgrp$ENSGRP
    sed -n -e "$line1,${line2}p"   filelist${nhr_assimilation}_tmp_ens$ENSGRP >filelist03_ensgrp$ENSGRP
    
# while loop
while IFS= read -r line
do
    echo "$line"
    case "$line" in 
     *ensmean*) export chg_memstring="ensmean_";;
     *mem0*)
      tmpstrg0=${line#*mem0}
      
      export inum=0${tmpstrg0:0:2}
      export chg_memstring="mem"${inum}"_"
      ;;
     *)
      echo something wrong in the file names, exit
           exit 999
        # display line or do somthing on $line
     esac 
   export  ATMANL=$line
   export  SFCANL=${ATMANL/atmf/sfcf} 
   export  SFCANL=${SFCANL/s.nemsio/.nemsio} 
   echo ATMANL and SFCANL are
   echo $ATMANL
   echo $SFCANL
   export DATA=${DATAbase}"f"${hour}${chg_memstring/"_"}
   export ensmemINPdir=${ensINPdir}/${chg_memstring%"_"} 
   mkdir -p ${ensmemINPdir}
   export OUTDIR=$DATA
   rm -fr $OUTDIR
   mkdir -p $OUTDIR




 if [ $machine = WCOSS_C ]; then
#
#create input file for cfp in order to run multiple copies of global_chgres_driver.sh simultaneously
#since we are going to run simulataneously, we want different working directories for each hour
#
  BC_DATA=/gpfs/hps3/ptmp/${LOGNAME}/wrk.chgres.$hour_name
  echo "env REGIONAL=2 bchour=$hour_name DATA=$BC_DATA $USHfv3/global_chgres_driver_hourly.sh >&out.chgres.$hour_name" >>bcfile.input
 elif [ $machine = DELL -a $tmmark = tm00 ]; then
  BC_DATA=$DATA/wrk.chgres.$hour_name
  echo "env REGIONAL=2 HALO=4 bchour=$hour_name DATA=$BC_DATA $USHfv3/dev-global_chgres_driver_dacycle_hourly.sh >&out.chgres.$hour_name" >>bcfile.input
 elif [ $machine = hera -o $machine = HERA -o $machine = WCOSS -o $machine = wcoss_cray -o $tmmark != tm00 ]; then
#
#for now on theia run the BC creation sequentially
#
  export REGIONAL=2
  export HALO=4
  $HOMEfv3/scripts/dev-make_ic.sh</dev/null
  mv $OUTDIR/gfs_bndy.tile7.${bchour}.nc $ensmemINPdir/.
  err=$?
  if [ $err -ne 0 ] ; then
    echo "bndy file not created, abort"
    exit 10
  fi
 fi
#
# for WCOSS_C we now run BC creation for all hours simultaneously
#
 if [ $machine = WCOSS_C ]; then
  export APRUNC=time
  export OMP_NUM_THREADS_CH=24      #default for openMP threads
  aprun -j 1 -n 28 -N 1 -d 24 -cc depth cfp bcfile.input
  export err=$?;err_chk
  rm bcfile.input
 elif [ $machine = DELL -a $tmmark = tm00 ]; then
# export OMP_NUM_THREADS_CH=24      #default for openMP threads
  mpirun cfp bcfile.input
  rm -f bcfile.input
 fi
done <"filelist03_ensgrp$ENSGRP"
else  # use a single control lbc
for imem in $(seq $ENSBEG $ENSEND); do

   echo "begin forecast for member ",$imem



   cmem=$(printf %03i $imem)
   memchar="mem$cmem"
  
   echo "Processing MEMBER: $cmem"
   if [ $tmmark = tm12 ] ; then 
   export ensmemINPdir=${ensINPdir}/${memchar} 
   else
   export ensmemINPdir=${ensINPdir}/$memchar
   fi
   mkdir -p $ensmemINPdir
   /bin/cp   $INPdir/gfs_bndy.tile7.${bchour}.nc $ensmemINPdir/gfs_bndy.tile7.${bchour}.nc
done 
fi
   hour=`expr $hour + $hour_inc`
done
exit

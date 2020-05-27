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
export CYCrun=`echo $CYCLE | cut -c 9-10`







#
#

#

# setup ensemble filelist03




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
echo "UTIL 0 is "$UTIL
python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=yes --minsize=${nens} -d ${COMINgfs}/enkfgdas -o filelist${nhr_assimilation}_tmp0_ens$ENSGRP --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes

sed '/ensmean/d'  filelist${nhr_assimilation}_tmp0_ens$ENSGRP> filelist${nhr_assimilation}_tmp_ens$ENSGRP 
cat filelist${nhr_assimilation}_tmp_ens$ENSGRP
#Check to see if ensembles were found 
numfiles=`cat filelist${nhr_assimilation}_tmp_ens$ENSGRP | wc -l`

if [ $numfiles -le $nens ]; then
  echo "Ensembles not found - turning off HYBENS!"
  export HYB_ENS=".false."
else
  # we have 81 files, figure out if they are all the right size
  # if not, set HYB_ENS=false
  . $UTIL/check_enkf_size.sh
fi

ENSGRP=${ENSGRP:-1}
ENSBEG=${ENSBEG:-1}
ENSEND=${ENSEND:-2}

#cltthink nens=`cat filelist03 | wc -l`
cp filelist${nhr_assimilation}_tmp_ens$ENSGRP $COMOUT/${RUN}.t${CYCrun}z.ens_chgres_filelist03.tm06

#head -${nens} filelist03>thinkdebfilelist03
    if [ $ENSGRP -eq 1 ]; then
       let "line1 = $ENSBEG   "
       let "line2 = $ENSEND  "
     else
       let "line1 = $ENSBEG   "
       let "line2 = $ENSEND "
    fi
#head -${nens} filelist03>filelist03_ensgrp$ENSGRP
    ls -l filelist${nhr_assimilation}_tmp_ens$ENSGRP
    sed -n -e "$line1,${line2}p"  filelist${nhr_assimilation}_tmp_ens$ENSGRP >filelist03_ensgrp$ENSGRP
    echo 'xxx'
    cat filelist03_ensgrp$ENSGRP

# while loop
while IFS= read -r line
do
    echo "first bob of the block for "$line
    echo "yyy"
done <"filelist03_ensgrp$ENSGRP"
while IFS= read -r line
do
    echo "bob of the block for "$line
    echo "$line"
    case "$line" in 
     *ensmean*)
        export chg_memstring="ensmean_"
        memstr=ensmean
       ;;
     *mem0*)
      tmpstrg0=${line#*mem0}
      
      export inum=0${tmpstrg0:0:2}
       memstr="mem"${inum}
      export chg_memstring="mem"${inum}"_"
      ;;
     *)
      echo something wrong in the file names, exit
           exit 999
        # display line or do somthing on $line
     esac 
   export ensmemINPdir=${ensINPdir}/${chg_memstring%"_"} 
   chg_memstringTrack=$chg_memstring
   rm -fr $ensmemINPdir
   mkdir -p ${ensmemINPdir}
   export  ATMANL=$line
   export  SFCANL=${ATMANL/atmf/sfcf} 
   export  SFCANL=${SFCANL/s.nemsio/.nemsio} 
   if [[ ! -e "$DATAFILE" ]];then
     SFCANL="NULL"
     export CONVERT_SFC=.false.
   else
     export CONVERT_SFC=.true.
   fi
   echo ATMANL and SFCANL are
   echo $ATMANL
   echo $SFCANL
   export DATA=${DATAbase}${chg_memstring/"_"}
   export OUTDIR=$DATA
   mkdir -p $OUTDIR


if [ $gtype = regional ] ; then
 export REGIONAL=1
 export HALO=4
#
# set the links to use the 4 halo grid and orog files
# these are necessary for creating the boundary data
# no need to do this every time it runs!
#
#ln -sf $FIXfv3/$CASE/${CASE}_grid.tile7.halo4.nc $FIXfv3/$CASE/${CASE}_grid.tile7.nc
#ln -sf $FIXfv3/$CASE/${CASE}_oro_data.tile7.halo4.nc $FIXfv3/$CASE/${CASE}_oro_data.tile7.nc
else
#
# for gtype = uniform, stretch or nest
#
 export REGIONAL=0
fi


#
#execute the chgres driver
#
unset chg_memstring 
#export convert_sfc=.true.
#export convert_nst=.true.
$HOMEfv3/scripts/dev-make_ic.sh</dev/null
export err=$?
if [ $err -ne 0 ] ; then
exit 199
fi

export res=768            #-- FV3 equivalent to 13-km global resolution
export RES=C$res
export RUN=${RES}_nest_$CDATE

#INPdir is $COMOUT/gfsanl.tm12, set in J-job

#ctlorg mv $OUTDIR/gfs*nc $INPdir/.
#cltorg mv $OUTDIR/sfc*nc $INPdir/.
 mv $OUTDIR/*gfs*nc  $ensmemINPdir
echo "tothink" 
if [ $CONVERT_SFC = ".false." ] ; then
#clt  cp $INPdir/*sfc*nc   $ensmemINPdir/ #clt using intial sfc of the control runs
cp $INPdir/sfc_data.tile7.nc  $ensmemINPdir/sfc_data.tile7.nc
fi
#Done with IC's generate boundary conditions
export REGIONAL=2
export convert_sfc=.false.
export convert_nst=.false.

#NHRSguess comes from JFV3SAR_ENVIR

hour=3
end_hour=$NHRSguess
while (test "$hour" -le "$end_hour")
 do
  if [ $hour -lt 10 ]; then  #clt to rewrite using printi command
   export hour_name='00'$hour
  elif [ $hour -lt 100 ]; then
   export hour_name='0'$hour
  else
   export hour_name=$hour
  fi
#cltthink  if [ $chg_memstringTrack = 'ensmean_' ]; then
#cltthink    unset ATMANL
#cltthink    unset SFCANL
#cltthink  else
    export vlddateLbcHr=`$NDATE +$hour $vlddate` 
      python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddateLbcHr --exact=yes --minsize=${nens} -d ${COMINgfs}/enkfgdas -o filelist${nhr_assimilation}_tmp_ens${ENSGRP}_LbcHr${hour} --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes
numfiles=`cat  filelist${nhr_assimilation}_tmp_ens${ENSGRP}_LbcHr${hour} | wc -l`
L_USE_CONTROL_LBC=.false.
if [ $numfiles -lt ${nens:-20} ]; then
  echo "Ensembles not found - turning off HYBENS!"
  export L_USE_CONTROL_LBC=".true."
fi
  
  export bchour=$hour_name
if [ $L_USE_CONTROL_LBC != ".true." ]; then
   export ATMANL=`grep $memstr filelist${nhr_assimilation}_tmp_ens${ENSGRP}_LbcHr${hour}` 
   echo   'ATMANL for lbc '$hour 'is ' $ATMANL
   export  SFCANL="NULL"
    
     
#cltthink  fi

 if [ $machine = WCOSS_C ]; then
#
#create input file for cfp in order to run multiple copies of global_chgres_driver.sh simultaneously
#
#since we are going to run simulataneously, we want different working directories for each hour
#
  BC_DATA=/gpfs/hps3/ptmp/${LOGNAME}/${chg_memstr}wrk.chgres.$hour_name
  echo "env REGIONAL=2 bchour=$hour_name DATA=$BC_DATA $USHfv3/global_chgres_driver.sh >&out.chgres.$hour_name" >>bcfile.input
 elif [ $machine = HERA -o  $machine = hera  -o $machine = WCOSS -o $machine = DELL -o $machine = wcoss_cray ]; then
#
#for now on theia run the BC creation sequentially
#
  export REGIONAL=2
  export HALO=4
#cltthinkdeb tothink now, the ATMAL is unset, the same global file (for control run ) will be used to get the fake ensemble lbc files
  $HOMEfv3/scripts/dev-make_ic.sh</dev/null
  unset ATMANL 
  unset SFCANL
  mv $OUTDIR/gfs_bndy.tile7.${bchour}.nc $ensmemINPdir/gfs_bndy.tile7.${bchour}.nc
  err=$?
  if [ $err -ne 0 ] ; then
    echo "bndy file not created, abort"
    exit 10
  fi
 fi
else  # use a single control lbc
   /bin/cp   $INPdir/gfs_bndy.tile7.${bchour}.nc $ensmemINPdir/gfs_bndy.tile7.${bchour}.nc
fi   
   hour=`expr $hour + 3`
unset bchour
done
#
# for WCOSS_C we now run BC creation for all hours simultaneously
#
  echo "eob of the block for"  $line
unset hour_name
done <"filelist03_ensgrp$ENSGRP"

exit

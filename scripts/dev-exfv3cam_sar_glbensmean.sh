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
export LEVS=65
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
NCP='/bin/cp -p'
NLN="/bin/ln -sf"

export GETSFCENSMEANEXEC=/scratch1/NCEPDEV/da/Catherine.Thomas/gsi/DA_GFSv16_delz/exec/getsfcensmeanp.x
export GETATMENSMEANEXEC=/scratch1/NCEPDEV/da/Catherine.Thomas/gsi/DA_GFSv16_delz/exec/getsigensmeanp_smooth.x
GETATMENSMEANEXEC=${GETATMENSMEANEXEC:-$HOMEgsi/exec/getsigensmeanp_smooth.x}
GETSFCENSMEANEXEC=${GETSFCENSMEANEXEC:-$HOMEgsi/exec/getsfcensmeanp.x}
cd $DATA
$NCP $GETSFCENSMEANEXEC . 
$NCP $GETATMENSMEANEXEC . 

#clt export OMP_NUM_THREADS=$NTHREADS_EPOS
export OMP_NUM_THREADS=1  #cltthink 

# setup ensemble filelist03




export CDAS=gfs
CRES=`echo $CASE | cut -c 2-`

#

#clt for treatments of ensembles 
export DATAbase=$DATA
# Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
export nhr_assimilation=03
##typeset -Z2 nhr_assimilation
export nens=20
rm -f filelist${nhr_assimilation}_tmp_ens$ENSGRP 
#clt python $UTIL/getbest_EnKF_mem_FV3GDAS.py -v $vlddate --exact=no --minsize=${nens} -d ${COMINgfs}/enkfgdas -o filelist${nhr_assimilation}_tmp_ens$ENSGRP --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes
python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=no --minsize=${nens} -d ${COMINgfs}/enkfgdas -o filelist${nhr_assimilation}_tmp_ens$ENSGRP --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes

cat filelist${nhr_assimilation}_tmp_ens$ENSGRP
#Check to see if ensembles were found 
numfiles=`cat filelist${nhr_assimilation}_tmp_ens$ENSGRP | wc -l`

if [ $numfiles -ne 5 ]; then
  echo "Ensembles not found - turning off HYBENS!"
  export HYB_ENS=".false."
else
  # we have 81 files, figure out if they are all the right size
  # if not, set HYB_ENS=false
  . $UTIL/check_enkf_size.sh
fi

 export ensmeamINPdir=${ensINPdir}/glbensmean_dir 

#cltthink nens=`cat filelist03 | wc -l`
sed '/ensmean/d'  filelist${nhr_assimilation}_tmp_ens> filelist${nhr_assimilation}_prep_ens
cp filelist${nhr_assimilation}_prep_ens $COMOUT/${RUN}.t${CYCrun}z.ens_prep_filelist03.tm06

#head -${nens} filelist03>thinkdebfilelist03
       let "line2 = $ENSEND + 1 "
#head -${nens} filelist03>filelist03_ensgrp$ENSGRP
    ls -l filelist${nhr_assimilation}_prep_ens
   
#cltlrg    sed -n -e "$line1,${line2}p"  filelist${nhr_assimilation}_tmp_ens$ENSGRP >filelist03_ensgrp$ENSGRP
    echo 'xxx'
    cp filelist${nhr_assimilation}_prep_ens filelist03_prep_ens
    cat filelist03_prep_ens

# while loop
line1=0
while IFS= read -r line
do
       let "line1 = $line1 + 1   "
      tmpstrg0=${line#*mem0}

      
      export inum=0${tmpstrg0:0:2}
       memchar="mem"${inum}
      ftemp=${line#*atmf} # strip off everything up to and including the '=' sign
      fhr=${ftemp:0:3} # get the next three characters.
      fhrchar=$(printf %03i $fhr)

################################################################################
# Forecast ensemble member files
      atmfile=$line
      sfcfile=${atmfile/atmf/sfcf}
      sfcfile=${sfcfile/s.nemsio/.nemsio}
      $NLN $sfcfile sfcf${fhrchar}_$memchar
      $NLN $atmfile atmf${fhrchar}_$memchar
      localSfcFile=`basename $sfcfile`
      locAtmFilemean=${localSfcFile/sfcf${fhrchar}.nemsio/atmf${fhrchar}.ensmean.nemsio}      
      locSfcFilemean=${localSfcFile/sfcf${fhrchar}.nemsio/sfcf${fhrchar}.ensmean.nemsio}      

  echo "eob of the block for"  $line
done <"filelist03_prep_ens"
   NMEM_ENKF=$line1
   $NLN $locSfcFilemean  sfcf${fhrchar}.ensmean
   $NLN $locAtmFilemean atmf${fhrchar}.ensmean
   $APRUN_EPOS ${DATA}/$(basename $GETSFCENSMEANEXEC) ./ sfcf${fhrchar}.ensmean sfcf${fhrchar}  $NMEM_ENKF
   ra=$?
   ((rc+=ra))
   $APRUNC ${DATA}/$(basename $GETATMENSMEANEXEC) ./ atmf${fhrchar}.ensmean atmf${fhrchar} $NMEM_ENKF
   ra=$?
   ((rc+=ra))
   mv gdas*ensmean.nemsio $FV3SAR_GLBensmeandir
   cp filelist${nhr_assimilation}_prep_ens $FV3SAR_GLBensmeandir/${RUN}.t${CYCrun}z.ens_prep_filelist03.tm06

# Forecast ensemble mean and smoothed files









   

exit

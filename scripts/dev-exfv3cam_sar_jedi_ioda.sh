#!/bin/bash
set -x
#SBATCH -J convert_diags_jedi 
#SBATCH -A fv3-cam
#SBATCH -q batch
#SBATCH --nodes=1
#SBATCH -t 0:08:00
#SBATCH -o /scratch2/NCEPDEV/stmp3/Shun.Liu/RRFS_IODA/tmpnwprd/log/rrfs_ioda.out_%j
#SBATCH -e /scratch2/NCEPDEV/stmp3/Shun.Liu/RRFS_IODA/tmpnwprd/log/rrfs_ioda.err_%j
#SBATCH --mail-user=$LOGNAME@noaa.gov
#DATE=2018041500

# load modules here used to compile GSI
#move module loading to module dir as other workflow task
#clt module purge
#clt module use -a /scratch1/NCEPDEV/da/Cory.R.Martin/Modulefiles
#clt module load modulefile.ProdGSI.hera
#clt module list

# load python module from Stelios
#clt module use -a /home/Stylianos.Flampouris/modulefiles
#clt module load anaconda/2019.08.07
#clt module load nccmp # for ctests
  echo "The script  begins to run"
  echo $PDYa
  IODACDir=${IODACdir:-/scratch2/NCEPDEV/fv3-cam/save/Shun.Liu/gsi/GSI_forJEDI/ush/JEDI/ioda-converters/build/bin}
  IODAdir=${IODAdir:-/scratch2/NCEPDEV/stmp3/Ting.Lei/RRFS_IODA/IODA/$PDYa}
  mkdir -p $IODAdir
  DIAGdir=${stmp:-/scratch2/NCEPDEV/stmp3/Ting.Lei}//RRFS_IODA/DIAG/diag.${PDYa}_${cyc}/${cyc}.${tmmark}}
  
  RADSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${ctrlstr+${ctrlstr}_}radstat.${tmmark}
  CNVSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${ctrlstr+${ctrlstr}_}cnvstat.${tmmark}


  rundir=${DATA}
  OutDir=$rundir
  GSIDIAG=$rundir/GSI_diags
  rm -fr $GSIDIAG
  mkdir -p $GSIDIAG
# cp $DIAGdir/diag_conv*ges* $GSIDIAG
  cd $GSIDIAG
   cp $CNVSTAT .
   tar xvf $( basename $CNVSTAT )
   rm -f  $( basename $CNVSTAT )
   gunzip *.gz
   rm -f ./*.gz

  fl=`ls -1 diag*`
  for ifl in $fl
  do
  leftpart=`basename $ifl .nc4`
  flnm=${leftpart}_ensmean.nc4
  echo $flnm
  mv $ifl $flnm
#  cp $ifl $flnm
  done
  echo "the diag files are listed as"
   ls -l  

#  cd $rrfs_ioda_dir
  OutDir=$rundir

#cd $IODACDir
#cltthinkde cp $IODACDir/{proc_gsi_ncdiag.py,subset_files.py} . 

rm -rf $OutDir/obs
rm -rf $OutDir/geoval
rm -rf $OutDir/log.proc_gsi_ncdiag
mkdir -p $OutDir/obs
mkdir -p $OutDir/geoval

#python ./proc_gsi_ncdiag.py -n 24 -o $OutDir/obs -g $OutDir/geoval $OutDir/GSI_diags
#for pyfile in "proc_gsi_ncdiag.py subset_files.py " ; do
#ln -sf ${IODACDir}/$pyfile .
#done
module list
ulimit -v unlimited
which python
#clt export HDF5_USE_FILE_LOCKING=FALSE
python ${IODACDir}/proc_gsi_ncdiag.py -n 1 -o $OutDir/obs -g $OutDir/geoval $OutDir/GSI_diags

# subset obs
python  ${IODACDir}/subset_files.py -n 1 -m $OutDir/obs -g $OutDir/geoval
python  ${IODACDir}/subset_files.py -n 1 -s $OutDir/obs -g $OutDir/geoval
     export ioda_converted_obs=${COMINrap_user}/ioda.${PDYa}
     mkdir -p $ioda_converted_obs
cp -r  $rundir/* $ioda_converted_obs
exit

# combine conventional obs
python ./combine_conv.py -i $OutDir/obs/sfc_*m.nc4 -o $OutDir/obs/sfc_obs_"$DATE"_m.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/sfcship_*m.nc4 -o $OutDir/obs/sfcship_obs_"$DATE"_m.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/aircraft_*m.nc4 -o $OutDir/obs/aircraft_obs_"$DATE"_m.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/sondes_ps*m.nc4 $OutDir/obs/sondes_q*m.nc4 $OutDir/obs/sondes_tsen*m.nc4 $OutDir/obs/sondes_uv*m.nc4 -o $OutDir/obs/sondes_obs_"$DATE"_m.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/sondes_ps*m.nc4 $OutDir/obs/sondes_q*m.nc4 $OutDir/obs/sondes_tv*m.nc4 $OutDir/obs/sondes_uv*m.nc4 -o $OutDir/obs/sondes_tvirt_obs_"$DATE"_m.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/sfc_*s.nc4 -o $OutDir/obs/sfc_obs_"$DATE"_s.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/sfcship_*s.nc4 -o $OutDir/obs/sfcship_obs_"$DATE"_s.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/aircraft_*s.nc4 -o $OutDir/obs/aircraft_obs_"$DATE"_s.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/sondes_ps*s.nc4 $OutDir/obs/sondes_q*s.nc4 $OutDir/obs/sondes_tsen*s.nc4 $OutDir/obs/sondes_uv*s.nc4 -o $OutDir/obs/sondes_obs_"$DATE"_s.nc4 -g $OutDir/geoval/
python ./combine_conv.py -i $OutDir/obs/sondes_ps*s.nc4 $OutDir/obs/sondes_q*s.nc4 $OutDir/obs/sondes_tv*s.nc4 $OutDir/obs/sondes_uv*s.nc4 -o $OutDir/obs/sondes_tvirt_obs_"$DATE"_s.nc4 -g $OutDir/geoval/

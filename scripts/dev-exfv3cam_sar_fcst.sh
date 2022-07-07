#!/bin/sh
############################################################################
# Script name:		run_regional_gfdlmp.sh
# Script description:	Run the 3-km FV3 regional forecast over the CONUS
#			using the GFDL microphysics scheme.
# Script history log:
#   1) 2018-03-14	Eric Rogers
#			run_nest.tmp retrieved from Eric's run_it directory.	
#   2) 2018-04-03	Ben Blake
#                       Modified from Eric's run_nest.tmp script.
#   3) 2018-04-13	Ben Blake
#			Various settings moved to JFV3_FORECAST J-job
#   4) 2018-06-19       Ben Blake
#                       Adapted for stand-alone regional configuration
############################################################################
#set -eux
set -x

export KMP_AFFINITY=scatter
export OMP_NUM_THREADS=2
export OMP_STACKSIZE=1024m

ulimit -s unlimited
ulimit -a

mkdir -p INPUT RESTART
if [ $tmmark = tm12 ] || [ $tmmark = tm06 -a ${l_coldstart_anal:-FALSE} = TRUE ] ; then
FcstInDir=${FcstInDir:-${COMOUT}/gfsanl.${tmmark}}
else
if [ ${l_coldstart_anal:-FALSE} = TRUE ] ; then
    FcstInDir_tmInit=${FcstInDir_tmInit:-${COMOUT}/gfsanl.tm06}
else
    FcstInDir_tmInit=${FcstInDir_tmInit:-${COMOUT}/gfsanl.tm12}
fi
ln -sf $FcstInDir_tmInit/gfs_data.tile7.nc INPUT/gfs_data.nc
FcstInDir=${FcstInDir:-${COMOUT}/anl.${tmmark}}
fi



#cltorg cp ${NWGES}/anl.${tmmark}/*.nc INPUT
cp $FcstInDir/*.nc INPUT

   if [ ${l_use_other_ctrlb_opt:-.false.} = .true. ] ; then
      OtherDirLbc=${COMOUT}/anl.${tmmark}
      cp $OtherDirLbc/*bndy*tile7*.nc INPUT 
     
   fi
#cltcp $ANLdir/fv_core.res.nc INPUT  #tothink temperaryily

numbndy=`ls -l INPUT/gfs_bndy.tile7*.nc | wc -l`
let "numbndy_check=$NHRS/3+1"

if [ $tmmark = tm00 ] ; then
  if [ $numbndy -lt $numbndy_check ] ; then
    export err=13
    echo "Don't have all BC files at tm00, abort run"
    err_exit "Don't have all BC files at tm00, abort run"
  fi
  elif  [ $tmmark = tm12 ] ; then 
   if [ $numbndy -lt 3 ] ; then
    export err=4
    echo "Don't have both BC files at ${tmmark}, abort run"
    err_exit "Don't have all BC files at ${tmmark}, abort run"
   fi
else
  if [ $numbndy -lt 2 ] ; then
    export err=2
    echo "Don't have both BC files at ${tmmark}, abort run"
    err_exit "Don't have all BC files at ${tmmark}, abort run"
  fi
fi

#---------------------------------------------- 
# Copy all the necessary fix files
#---------------------------------------------- 
cp $FIXam/global_solarconstant_noaa_an.txt            solarconstant_noaa_an.txt
cp $FIXam/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77  global_o3prdlos.f77
cp $FIXam/global_h2o_pltc.f77                         global_h2oprdlos.f77
cp $FIXam/global_sfc_emissivity_idx.txt               sfc_emissivity_idx.txt
cp $FIXam/global_co2historicaldata_glob.txt           co2historicaldata_glob.txt
cp $FIXam/co2monthlycyc.txt                           co2monthlycyc.txt
cp $FIXam/global_climaeropac_global.txt               aerosol.dat

cp $FIXam/global_glacier.2x2.grb .
cp $FIXam/global_maxice.2x2.grb .
cp $FIXam/RTGSST.1982.2012.monthly.clim.grb .
cp $FIXam/global_snoclim.1.875.grb .
cp $FIXam/CFSR.SEAICE.1982.2012.monthly.clim.grb .
cp $FIXam/global_soilmgldas.t1534.3072.1536.grb .
cp $FIXam/seaice_newland.grb .
cp $FIXam/global_shdmin.0.144x0.144.grb .
cp $FIXam/global_shdmax.0.144x0.144.grb .

ln -sf $FIXsar/C${CRES}.maximum_snow_albedo.tile7.halo0.nc C${CRES}.maximum_snow_albedo.tile1.nc
ln -sf $FIXsar/C${CRES}.snowfree_albedo.tile7.halo0.nc C${CRES}.snowfree_albedo.tile1.nc
ln -sf $FIXsar/C${CRES}.slope_type.tile7.halo0.nc C${CRES}.slope_type.tile1.nc
ln -sf $FIXsar/C${CRES}.soil_type.tile7.halo0.nc C${CRES}.soil_type.tile1.nc
ln -sf $FIXsar/C${CRES}.vegetation_type.tile7.halo0.nc C${CRES}.vegetation_type.tile1.nc
ln -sf $FIXsar/C${CRES}.vegetation_greenness.tile7.halo0.nc C${CRES}.vegetation_greenness.tile1.nc
ln -sf $FIXsar/C${CRES}.substrate_temperature.tile7.halo0.nc C${CRES}.substrate_temperature.tile1.nc
ln -sf $FIXsar/C${CRES}.facsf.tile7.halo0.nc C${CRES}.facsf.tile1.nc


for file in `ls $FIXco2/global_co2historicaldata* ` ; do
  cp $file $(echo $(basename $file) |sed -e "s/global_//g")
done

#---------------------------------------------- 
# Copy tile data and orography for regional
#---------------------------------------------- 
ntiles=1
tile=7
HALO=4
NH3=3
cp $FIXsar/${CASE}_grid.tile${tile}.halo3.nc INPUT/.
cp $FIXsar/${CASE}_grid.tile${tile}.halo4.nc INPUT/.
cp $FIXsar/${CASE}_oro_data.tile${tile}.halo0.nc INPUT/.
cp $FIXsar/${CASE}_oro_data.tile${tile}.halo4.nc INPUT/.
cp $FIXsar/${CASE}_mosaic.halo${NH3}.nc INPUT/${CASE}_mosaic.nc
  
cd INPUT
ln -sf ${CASE}_mosaic.nc grid_spec.nc
ln -sf ${CASE}_grid.tile7.halo3.nc ${CASE}_grid.tile7.nc
ln -sf ${CASE}_grid.tile7.halo4.nc grid.tile7.halo4.nc
ln -sf ${CASE}_oro_data.tile7.halo0.nc oro_data.nc
ln -sf ${CASE}_oro_data.tile7.halo4.nc oro_data.tile7.halo4.nc
# Initial Conditions are needed for SAR but not SAR-DA
if [ $tmmark = tm12 ] || [ $tmmark = tm06 -a ${l_coldstart_anal:-FALSE} = TRUE ] ; then
  ln -sf sfc_data.tile7.nc sfc_data.nc
  ln -sf gfs_data.tile7.nc gfs_data.nc
fi

cd ..
#if [ $tmmark = tm12 ] ; then
#cp ${CONFIGdir}/diag_table_tmp . #clt diag_table_mp.tmp
#cp ${CONFIGdir}/data_table .
#cp ${CONFIGdir}/field_table .
#fi



#-------------------------------------------------------------------
# Copy or set up files data_table, diag_table, field_table,
#   input.nml, input_nest02.nml, model_configure, and nems.configure
#-------------------------------------------------------------------

if [ $tmmark = tm00 ] ; then
	if [ $MPSUITE = thompson ] ; then
	  CCPP_SUITE=${CCPP_SUITE:-"FV3_GFS_v15_thompson_mynn_lam3km"}
	  cp ${PARMfv3}/thompson/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
	fi
	if [ $MPSUITE = gfdlmp ] ; then
	  CCPP_SUITE=${CCPP_SUITE:-"FV3_GFS_2017_gfdlmp_regional"}
	  cp ${PARMfv3}/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
	fi

# Free forecast with DA (warm start)
  if [ $model = fv3sar_da ] ; then
    if [ ${MPSUITE:-thompson} = thompson ] ; then
      cp ${PARMfv3}/thompson/input_sar_da.nml input.nml.tmp
    fi
    if [ $MPSUITE = gfdlmp ] ; then

        cp ${PARMfv3}/input_sar_da.nml input.nml.tmp 
    fi

    
# Free forecast without DA (cold start)
  elif [ $model = fv3sar ] ; then 
      echo "think tobe done exit"
      exit 999
   if [ $CCPP  = true ] || [ $CCPP = TRUE ] ; then
      cp ${PARMfv3}/input_sar_${dom}_ccpp.nml input.nml.tmp
      cat input.nml.tmp | sed s/CCPP_SUITE/\'$CCPP_SUITE\'/ >  input0.nml
      mv input0.nml input.nml.tmp
      cp ${PARMfv3}/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
    else
      cp ${PARMfv3}/input_sar_${dom}.nml input.nml
      if [ $dom = conus ] ; then
        mv input.nml input.nml.tmp
        cat input.nml.tmp | \
            sed s/_TASK_X_/${TASK_X}/ | sed s/_TASK_Y_/${TASK_Y}/  >  input.nml
      elif [ ! -e input.nml ] ; then
         echo "FATAL ERROR: no input_sar_${dom}.nml in PARMfv3 directory.  Create one!"
      fi
    fi

  fi
   

  cp ${PARMfv3}/model_configure_sar.tmp_${dom:-conus}_${CASE} model_configure.tmp

	if [ ${dom:-conus} = "conus" ]
	then
	  nodes=76 
	elif [ $dom = "ak" ]
	then
	  nodes=68
	elif [ $dom = "pr" ]
	then
	  nodes=10
	elif [ $dom = "hi" ]
	then
	  nodes=7
	elif [ $dom = "guam" ]
	then
	  nodes=7
	fi

	ncnode=24
	let nctsk=ncnode/OMP_NUM_THREADS    # 12 tasks per node with 2 threads 
	let ntasks=nodes*nctsk
	echo nctsk = $nctsk and ntasks = $ntasks
	if [ $MPSUITE = thompson ] ; then
	  cp ${PARMfv3}/thompson/diag_table.tmp .
	  cp ${PARMfv3}/thompson/field_table .
	  cp $PARMfv3/thompson/CCN_ACTIVATE.BIN                          CCN_ACTIVATE.BIN
	  cp $PARMfv3/thompson/freezeH2O.dat                             freezeH2O.dat
	  cp $PARMfv3/thompson/qr_acr_qg.dat                             qr_acr_qg.dat
	  cp $PARMfv3/thompson/qr_acr_qs.dat                             qr_acr_qs.dat
	  cp $PARMfv3/thompson/thompson_tables_precomp.sl                thompson_tables_precomp.sl
	fi
	if [ $MPSUITE = gfdlmp ] ; then
	  cp ${PARMfv3}/diag_table.tmp .
	  cp ${PARMfv3}/field_table .
	fi

	cp ${PARMfv3}/data_table .
	cp ${PARMfv3}/nems.configure .


# Submit post manager here
elif [ $tmmark = tm12 ] || [ $tmmark = tm06 -a ${l_coldstart_anal:-FALSE} = TRUE ] ; then



      if [ $MPSUITE = thompson ] ; then
         CCPP_SUITE=${CCPP_SUITE:-"FV3_GFS_v15_thompson_mynn_lam3km"}
         cp ${PARMfv3}/thompson/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
#         CCPP_SUITE="FV3_RRFS_v1beta"

            
         cp ${PARMfv3}/thompson/input_sar_firstguess.nml input.nml.tmp
         cp ${PARMfv3}/thompson/diag_table.tmp .
         cp ${PARMfv3}/thompson/field_table .
         cp $PARMfv3/thompson/CCN_ACTIVATE.BIN                          CCN_ACTIVATE.BIN
         cp $PARMfv3/thompson/freezeH2O.dat                             freezeH2O.dat
         cp $PARMfv3/thompson/qr_acr_qg.dat                             qr_acr_qg.dat
         cp $PARMfv3/thompson/qr_acr_qs.dat                             qr_acr_qs.dat
         cp $PARMfv3/thompson/thompson_tables_precomp.sl                thompson_tables_precomp.sl
      fi
    
      if [ $MPSUITE = gfdlmp ] ; then
        cp ${PARMfv3}/input_sar_firstguess.nml input.nml.tmp
        CCPP_SUITE=${CCPP_SUITE:-"FV3_GFS_2017_gfdlmp_regional"}
        cp ${PARMfv3}/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
        cp ${PARMfv3}/diag_table.tmp .
       	cp ${PARMfv3}/field_table .
     fi
        if [  ${l_coldstart_anal:-FALSE} = TRUE ] ; then
            sed -i  -e "/bc_update_interval.*=/ s/=.*/= 1/"  input.nml.tmp
        fi
  #cltthinkdeb tothink 
	cp ${PARMfv3}/model_configure_sar_firstguess.tmp_${CASE} model_configure.tmp
        cp ${PARMfv3}/data_table .
	cp ${PARMfv3}/nems.configure .
#thinkdeb do we need consider  if [ $CCPP  = true ] || [ $CCPP = TRUE ] ; then

else
	if [ $MPSUITE = thompson ] ; then
	  CCPP_SUITE=${CCPP_SUITE:-"FV3_GFS_v15_thompson_mynn_lam3km"}
	  cp ${PARMfv3}/thompson/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
	fi
	if [ $MPSUITE = gfdlmp ] ; then
	  CCPP_SUITE=${CCPP_SUITE:-"FV3_GFS_2017_gfdlmp_regional"}
	  cp ${PARMfv3}/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
	fi
   

#clt for bblake  cp ${PARMfv3}/input_sar_da_hourly.nml input.nml
#for bblake   cp ${PARMfv3}/model_configure_sar_da_hourly.tmp model_configure.tmp
  if [ $MPSUITE = thompson ] ; then
#cltfor subdomain     cp ${PARMfv3}/thompson/input_sar_da_hourly.nml_subdomain input.nml.tmp
    cp ${PARMfv3}/thompson/input_sar_da_hourly.nml input.nml.tmp
  fi
  if [ $MPSUITE = gfdlmp ] ; then
    cp ${PARMfv3}/input_sar_da_hourly.nml input.nml.tmp
  fi

  if [ $MPSUITE = thompson ] ; then
    cp ${PARMfv3}/thompson/diag_table.tmp .
    cp ${PARMfv3}/thompson/field_table .
    cp $PARMfv3/thompson/CCN_ACTIVATE.BIN                          CCN_ACTIVATE.BIN
    cp $PARMfv3/thompson/freezeH2O.dat                             freezeH2O.dat
    cp $PARMfv3/thompson/qr_acr_qg.dat                             qr_acr_qg.dat
    cp $PARMfv3/thompson/qr_acr_qs.dat                             qr_acr_qs.dat
    cp $PARMfv3/thompson/thompson_tables_precomp.sl                thompson_tables_precomp.sl
  fi
  if [ $MPSUITE = gfdlmp ] ; then
    cp ${PARMfv3}/diag_table.tmp .
    cp ${PARMfv3}/field_table .
  fi
  

  cp ${PARMfv3}/model_configure_sar_da_hourly.tmp_${CASE} model_configure.tmp

  cp ${PARMfv3}/data_table .
  cp ${PARMfv3}/nems.configure .
fi
#Copy UPP parm files for inline post
cp ${PARMfv3}/post_itag                 ./itag
cp ${PARMfv3}/nam_micro_lookup.dat      ./eta_micro_lookup.dat
cp ${PARMfv3}/postxconfig-NT-fv3lam.txt ./postxconfig-NT.txt
cp ${PARMfv3}/postxconfig-NT-fv3lam.txt ./postxconfig-NT_FH00.txt
cp ${PARMfv3}/params_grib2_tbl_new      ./params_grib2_tbl_new


if [ ${L_LBC_UPDATE:-FALSE} = TRUE -a $tmmark != tm00  ];then
 if [ $tmmark = tm12 ] || [ $tmmark = tm06 -a ${l_coldstart_anal:-FALSE} = TRUE ] ; then
#     if [ $tmmark = tm00 ] ; then
   regional_bcs_from_gsi=.false.
   write_restart_with_bcs=.true.
   nrows_blend=${NROWS_BLEND:-10}
 elif [ $tmmark = tm00 ];then
  if [ -z ${MEMBER+x} ]; then  #MEMBER not defined , for control run
   regional_bcs_from_gsi=.true.
   write_restart_with_bcs=.false.
   nrows_blend=${NROWS_BLEND:-10}
  else
   regional_bcs_from_gsi=.false.
   write_restart_with_bcs=.false.
   nrows_blend=${NROWS_BLEND:-10}
  fi
 else
  if [ -z ${MEMBER+x} ]; then  #MEMBER not defined , for control run
   regional_bcs_from_gsi=.true.
   write_restart_with_bcs=.true.
   nrows_blend=${NROWS_BLEND:-10}
  else
   regional_bcs_from_gsi=.false.
   write_restart_with_bcs=.true.
   nrows_blend=${NROWS_BLEND:-10}
  fi

 fi
   

else
   regional_bcs_from_gsi=.false.
   write_restart_with_bcs=.false.
   nrows_blend=${NROWS_BLEND:-0}
fi
  cat input.nml.tmp | \
     sed s/_TASK_X_/${TASK_X}/ | sed s/_TASK_Y_/${TASK_Y}/  >  input.nml
   sed -i  -e "s/XCRESX/${CASE}/"   input.nml
   sed -i  -e "/regional_bcs_from_gsi.*=/ s/=.*/= $regional_bcs_from_gsi/"  input.nml
   sed -i  -e "/write_restart_with_bcs.*=/ s/=.*/= $write_restart_with_bcs/"  input.nml
   sed -i  -e "/nrows_blend.*=/ s/=.*/= $nrows_blend/"  input.nml
   sed -i  -e "/npx .*=/ s/=.*/= ${NPX}/"  input.nml
   sed -i  -e "/npy .*=/ s/=.*/= ${NPY}/"  input.nml
   sed -i  -e "/npz .*=/ s/=.*/= $((LEVS-1))/"  input.nml
   sed -i  -e "/levp .*=/ s/=.*/= ${LEVS}/"  input.nml

 if [ ${l_stochastic_pert:-FALSE} = TRUE ] ; then
   number=$(echo mem009 |tr -dc '0-9'|cut -c2-3 )  #following setup by Jili 
   number2=${PDYfcst}${CYCfcst}${number}
   iseed_shum=${number2}2
   iseed_skeb=${number2}3
   iseed_sppt=${number2}1
   sed -i  -e "/do_sppt .*=/ s/=.*/= .true. /"  input.nml
   sed -i  -e "/do_shum .*=/ s/=.*/= .true. /"  input.nml
   sed -i  -e "/do_skeb .*=/ s/=.*/= .true. /"  input.nml
   sed -i  -e "/iseed_sppt .*=/ s/=.*/=${iseed_sppt}   /"  input.nml
   sed -i  -e "/iseed_skeb .*=/ s/=.*/=${iseed_skeb}   /"  input.nml
   sed -i  -e "/iseed_shum .*=/ s/=.*/=${iseed_shum}   /"  input.nml


 fi





#cp diag_table_tmp diag_table.tmp

if [ $tmmark = tm12 ] ; then
CYCLEtm12=`$NDATE -12 $CYCLE`
yr=`echo $CYCLEtm12 | cut -c1-4`
mn=`echo $CYCLEtm12 | cut -c5-6`
dy=`echo $CYCLEtm12 | cut -c7-8`
hr=`echo $CYCLEtm12 | cut -c9-10`
else
yr=`echo $CYCLEanl | cut -c1-4`
mn=`echo $CYCLEanl | cut -c5-6`
dy=`echo $CYCLEanl | cut -c7-8`
hr=`echo $CYCLEanl | cut -c9-10`
fi


if [ $tmmark = tm00 ] ; then
  NFCSTHRS=$NHRS
  RESTART_INTERVAL=24
  NRST=12
elif  [ $tmmark = tm12 ] ; then 
  NFCSTHRS=$NHRSguess
  RESTART_INTERVAL=6
  NRST=6
else
  NFCSTHRS=$NHRSda
  RESTART_INTERVAL=1
  NRST=01
fi
cat > temp << !
${yr}${mn}${dy}.${cyc}Z.${CASE}.32bit.non-hydro
$yr $mn $dy $hr 0 0
!

cat temp diag_table.tmp > diag_table

#if [ $tmmark = tm12 ] ; then
if [ $tmmark = tm12 ] || [ $tmmark = tm06 -a ${l_coldstart_anal:-FALSE} = TRUE ] ; then
    cat model_configure.tmp | sed s/NTASKS/$TOTAL_TASKS/ | sed s/YR/$yr/ | \
    sed s/MN/$mn/ | sed s/DY/$dy/ | sed s/H_R/$hr/ | \
    sed s/NHRS/$NFCSTHRS/ | sed s/NTHRD/$OMP_NUM_THREADS/ | \
    sed s/_WG_/${WG}/ | sed s/_WTPG_/${WTPG}/  |             \
    sed s/NCNODE/$NCNODE/  >  model_configure

else
  cat model_configure.tmp | sed s/NTASKS/$TOTAL_TASKS/ | sed s/YR/$yr/ | \
    sed s/MN/$mn/ | sed s/DY/$dy/ | sed s/H_R/$hr/ | \
    sed s/NHRS/$NFCSTHRS/ | sed s/NTHRD/$OMP_NUM_THREADS/ | \
    sed s/NCNODE/$NCNODE/ | sed s/NRESTART/$NRST/ | \
    sed s/_WG_/${WG}/ | sed s/_WTPG_/${WTPG}/  >  model_configure
fi
    sed -i -e "/restart_interval.*:/ s/:.*/: $RESTART_INTERVAL/" model_configure 

#----------------------------------------- 
# Run the forecast
#-----------------------------------------
if [ ${L_LBC_UPDATE:-FALSE} = TRUE   ];then
#cltorg before 20201210  ln -sf $FIXfv3/save_RESTART_${MPSUITE}/fv_core.res.tile1.nc ./INPUT/fv_core.res.temp.nc  
#cltorg before 20201210  ln -sf $FIXfv3/save_RESTART_${MPSUITE}/fv_tracer.res.tile1.nc ./INPUT/fv_tracer.res.temp.nc 
# processing for inserting GSI into bndy files
mkdir create_expanded_restart_files_for_DA
cd create_expanded_restart_files_for_DA
cp ../field_table .
cp ../input.nml .
cp $HOMEfv3/regional_da_imbalance/create_expanded_restart_files_for_DA.x .
ls -l create_expanded_restart_files_for_DA.x
./create_expanded_restart_files_for_DA.x
#ncltthink 
cp fv_core.res.tile1_new.nc ../RESTART/.
cp fv_tracer.res.tile1_new.nc ../RESTART/.
ls -l ../RESTART/
cd ..
fi
#cltsed -i '/npz_type/d' input.nml
#export pgm=regional_forecast.x
export pgm=regional_forecast.x

#. prep_step

#startmsg

#clt . prep_step

tothink
if [ ${newfcst_exec:-NONE} = NONE  ]; then
${APRUNC}  /scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-unified-workflow/ufs-weather-model/tests/fv3_32bit.exe >$pgmout 2>err
else
${APRUNC}  $newfcst_exec >$pgmout 2>err

fi
export err=$? #cltthinkdeb ;err_chk
if [ $err -ne 0 ]; then
 exit 999
fi

# Copy files needed for next analysis
# use grid_spec.nc file output from model in working directory,
# NOT the one in the INPUT directory......

# GUESSdir, ANLdir set in J-job

FcstOutDir=${FcstOutDir:-$GUESSdir}
if [ $tmmark != tm00 ] ; then
  cp grid_spec.nc* $FcstOutDir/.
!clt  cp grid_spec.nc RESTART
  cd RESTART
#cltorg   mv ${PDYfcst}.${CYCfcst}0000.coupler.res $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}coupler.res
#cltorg   mv ${PDYfcst}.${CYCfcst}0000.fv_core.res.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_core.res.nc
#cltorg   mv ${PDYfcst}.${CYCfcst}0000.fv_core.res.tile1.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_core.res.tile1.nc
#cltorg   mv ${PDYfcst}.${CYCfcst}0000.fv_tracer.res.tile1.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_tracer.res.tile1.nc
#cltorg  mv ${PDYfcst}.${CYCfcst}0000.sfc_data.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}sfc_data.nc


  mv coupler.res $FcstOutDir/${PDYfcst}.${CYCfcst}0000.coupler.res
  mv fv_core.res.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_core.res.nc
 
  strtmp="$FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}"
#cltorg  mv fv_core.res.tile1.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_core.res.tile1.nc
  ls fv_core.res.tile1.nc* |xargs -I % sh -c "mv % ${strtmp}%" 
#  mv fv_tracer.res.tile1.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_tracer.res.tile1.nc
  ls  fv_tracer.res.tile1.nc* | xargs -I % sh -c "mv % ${strtmp}%"
#  cp sfc_data.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}sfc_data.nc
  ls  sfc_data.nc* | xargs -I % sh -c "mv % ${strtmp}%" 
#  cp fv_srf_wnd.res.tile1.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_srf_wnd.res.tile1.nc
  ls  fv_srf_wnd.res.tile1.nc* | xargs -I % sh -c "mv % ${strtmp}%" 


# These are not used in GSI but are needed to warmstart FV3
# so they go directly into ANLdir
#cltorg  mv ${PDYfcst}.${CYCfcst}0000.phy_data.nc $FcstOutDir/phy_data.nc
#  mv phy_data.nc $FcstOutDir/phy_data.nc
  ls phy_data.nc $FcstOutDir/phy_data.nc* | xargs -I % sh -c "mv % ${strtmp}%"

if [[ ! $FcstOutDir =~ mem ]];then  #for control run
  mv fv_srf_wnd.res.tile1.nc $ANLdir/${PDYfcst}.${CYCfcst}0000.fv_srf_wnd.res.tile1.nc
fi

if [[ ${L_LBC_UPDATE:-FALSE} = TRUE ]];then
  #Move enlarged restart files for 00-h BC's
   mv fv_tracer.res.tile1_new.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_tracer.res.tile1_new.nc 
   mv fv_core.res.tile1_new.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}fv_core.res.tile1_new.nc 
  # Make enlarged sfc file
  mv sfc_data.nc sfc_data_orig.nc
  mv grid_spec.nc grid_spec_orig.nc

  cp $HOMEfv3/regional_da_imbalance/prep_for_regional_DA.x .
  cp $FIXsar/${CASE}_grid.tile7.halo3.nc grid.tile7.halo3.nc
  ./prep_for_regional_DA.x

  mv sfc_data_new.nc $FcstOutDir/${PDYfcst}.${CYCfcst}0000.${memstr+"_${memstr}_"}sfc_data_new.nc
  mv grid_spec_new.nc $FcstOutDir/grid_spec_new.nc

fi




fi
exit

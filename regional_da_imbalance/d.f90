!-----------------------------------------------------------------------
      program prep_for_regional_DA
!-----------------------------------------------------------------------
!***  When the regional DA includes boundary rows in the core and
!***  tracers restart files it needs those extra rows of data in
!***  the sfc_data.nc file as well.  It learns the size of the
!***  enlarged grid and the lats/lons of the grid box centers and
!***  corners from the grid_spec.nc file so that file also must
!***  be modified.
!-----------------------------------------------------------------------
      use netcdf
!-----------------------------------------------------------------------
      implicit none
!-----------------------------------------------------------------------
!
      integer,parameter :: double=selected_real_kind(p=13,r=200)           !<-- Define KIND for double precision real
!
      integer,parameter :: num_dims_sfc=4
      integer,parameter :: num_dims_grid=5
      integer,parameter :: halo=3
!
      integer :: i,iend_new,istart_new,j,jend_new,jstart_new,k,kend
!
      integer :: n,na,natts,nd,ndims,nctype,ngatts,nvars,var_id,var_id_new
!
      integer :: ncid_grid_spec_new,ncid_grid_spec_orig,ncid_grid_tile  &
                ,ncid_sfc_new,ncid_sfc_orig
!
      integer,dimension(:),allocatable :: dimids
!
      integer,dimension(num_dims_sfc) :: dimid_sfc 
      integer,dimension(num_dims_sfc) :: dimid_sfc_new 
      integer,dimension(num_dims_grid) :: dimid_grid
!
      integer,dimension(:),allocatable :: dimsize_new                   &
                                         ,dimsize_orig
!
      integer:: ii
      real :: zero=0.
!
      real(kind=double),dimension(:,:),allocatable :: field_dbl
      real,dimension(:,:),allocatable :: field
!
      real,dimension(:),allocatable :: grid_point_count
!
      character(len=50) :: name_att,name_var
!
      character(len=20) :: filename_sfc_data_orig='sfc_data_orig.nc'    &  !<-- The original standard-sized sfc_data.nc file
                          ,filename_sfc_data_new='sfc_data_new.nc'         !<-- The same file but with data in the boundary rows
!
      character(len=20) :: filename_grid_spec_orig='grid_spec_orig.nc'  &  !<-- The original grid_spec.nc file.
                          ,filename_grid_spec_new='grid_spec_new.nc'       !<-- The new grid_spec.nc file with boundary rows.
!
      character(len=20) :: filename_grid_tile='grid.tile7.halo3.nc'        !<-- The grid file from regional pre-processing.
!
      character(len=20),dimension(num_dims_sfc) :: dimname_sfc=(/          &
                                                                 'xaxis_1' &
                                                                ,'yaxis_1' &
                                                                ,'zaxis_1' &
                                                                ,'Time'    &
                                                                /)
!
      character(len=20),dimension(num_dims_grid) :: dimname_grid=(/        &
                                                                 'grid_x'  &
                                                                ,'grid_y'  &
                                                                ,'time'    &
                                                                ,'grid_xt' &
                                                                ,'grid_yt' &
                                                                 /)
!
!-----------------------------------------------------------------------
!***********************************************************************
!-----------------------------------------------------------------------
!
!-----------------------------------------------------------------------
!***  Begin with creating the enlarged sfc_data file.
!-----------------------------------------------------------------------
!
!-----------------------------------------------------------------------
!***  Open the original sfc_data file.
!-----------------------------------------------------------------------
!
      call check(nf90_open(filename_sfc_data_orig,nf90_nowrite,ncid_sfc_orig))
!
!-----------------------------------------------------------------------
!***  We must reproduce the original sfc_data file in an enlarged
!***  version that includes the boundary rows.  Create the new
!***  sfc_data file then add the dimensions, variables, attributes, etc.
!-----------------------------------------------------------------------
!
      call check(nf90_create(filename_sfc_data_new,nf90_clobber,ncid_sfc_new))
!
!---------------
!*** Dimensions
!---------------
!
      allocate(dimsize_orig(1:num_dims_sfc))
      allocate(dimsize_new(1:num_dims_sfc))
!cltorg      allocate(dimids(1:num_dims_sfc))
      allocate(dimids(1:NF90_MAX_VAR_DIMS))
      dimids(:)=0
!
      do n=1,num_dims_sfc                                                  !<-- The # of dimensions in the sfc_data file
        call check(nf90_inq_dimid(ncid_sfc_orig                         &  !<-- The file ID
                                 ,dimname_sfc(n)                        &  !<-- The dimension's name
                                 ,dimid_sfc(n)))                           !<-- The dimensions's ID
!
        call check(nf90_inquire_dimension(ncid_sfc_orig                 &  !<-- The sfc_data file ID
                                         ,dimid_sfc(n)                  &  !<-- The dimensions's ID
                                         ,len=dimsize_orig(n)))            !<-- The dimension's value 
      enddo
!
      dimsize_new(1)=dimsize_orig(1)+2*halo
      write(6,*)'dimsiz new 1 ',dimsize_new(1)
      dimsize_new(2)=dimsize_orig(2)+2*halo
      write(6,*)'dimsiz new 2 ',dimsize_new(2)
      dimsize_new(3)=dimsize_orig(3)
      write(6,*)'dimsiz new 3 ',dimsize_new(3)
      dimsize_new(4)=dimsize_orig(4)
      write(6,*)'dimsiz new 4 ',dimsize_new(4)
      do n=1,num_dims_sfc                                                  !<-- The # of dimensions in the sfc_data file
        call check(nf90_def_dim(ncid_sfc_new,dimname_sfc(n),dimsize_new(n),dimid_sfc_new(n)))  !<-- Define dims in the enlarged sfc file.
      enddo
!---------------
!***  Variables
!---------------
!
      call check(nf90_inquire(ncid_sfc_orig,nvariables=nvars))             !<-- The total number of sfc_data file variables
!
      do n=1,nvars    
        var_id=n
        call check(nf90_inquire_variable(ncid_sfc_orig,var_id,name_var,nctype &  !<-- Name and type of this variable
                  ,ndims,dimids,natts))                                          !<-- # of dimensions and attributes in this variable
!
!clt        call check(nf90_def_var(ncid_sfc_new,name_var,nctype,dimids(1:ndims),var_id_new)) !<-- Define the variable in the new sfc file.
        call check(nf90_def_var(ncid_sfc_new,name_var,nctype,dimids(1:ndims),var_id_new)) !<-- Define the variable in the new sfc file.
!
!-----------------------------------------------------------------------
!***  Copy this variable's attributes to the new file's variable.
!-----------------------------------------------------------------------
!
        if(natts>0)then
          do na=1,natts
            call check(nf90_inq_attname(ncid_sfc_orig,var_id,na,name_att))                !<-- Get the attribute's name and ID from original
            call check(nf90_copy_att(ncid_sfc_orig,var_id,name_att,ncid_sfc_new,var_id_new))  !<-- Copy to the new sfc_data file
          enddo
        endif
!
      enddo
!
!-----------------------
!***  Global attributes
!-----------------------
!
      call check(nf90_inquire(ncid_sfc_orig,nattributes=ngatts))
!
      do n=1,ngatts
        call check(nf90_inq_attname(ncid_sfc_orig,NF90_GLOBAL,n,name_att))
        call check(nf90_copy_att(ncid_sfc_orig,NF90_GLOBAL,name_att,ncid_sfc_new,NF90_GLOBAL))
      enddo
!
!-----------------------------------------------------------------------
!***  We are finished with definitions so put the new enlarged
!***  sfc_data file into data mode.
!-----------------------------------------------------------------------
!
      call check(nf90_enddef(ncid_sfc_new))
!
!-----------------------------------------------------------------------
!***  Loop through all the variables skipping those that are the
!***  dimensions.  Read each field into the interior of an array 
!***  the size of the enlarged domain.
!-----------------------------------------------------------------------
!
      allocate(field_dbl(1:dimsize_new(1),1:dimsize_new(2)))
      field_dbl(:,:)=9.e9
!
      istart_new=halo+1                                                    !<--
      iend_new=dimsize_orig(1)+halo                                        !  The index limits of the original
      jstart_new=halo+1                                                    !  data in the enlarged domain.
      jend_new=dimsize_orig(2)+halo                                        !<--
!
!-----------------------------------------------------------------------
      vbls: do n=num_dims_sfc+1,nvars
!-----------------------------------------------------------------------
!
        call check(nf90_inquire_variable(ncid_sfc_orig,n,ndims=ndims))
!
        kend=1
        if(ndims==4)then
          kend=dimsize_new(3)                                              !<-- Time is a dimension; k will be the 3rd dimension
        endif
!
        do k=1,kend
          call check(nf90_get_var(ncid_sfc_orig,n                       &
                    ,field_dbl(istart_new:iend_new,jstart_new:jend_new) &  !<-- The full field array with BC rows for layer k
                    ,start=(/1,1,k/)                                    &
                    ,count=(/dimsize_orig(1),dimsize_orig(2),1/)))
!
!-----------------------------------------------------------------------
!***  Fill in the boundary rows with the values from the outer
!***  integration row.  Finesse the corners since these extended
!***  values are not critical; essentially just extend the 
!***  values from the outer row of the compute domain into the
!***  boundary.
!-----------------------------------------------------------------------
!
!-----------
!***  North
!-----------
!
          do j=1,halo
            do i=halo+1,dimsize_new(1)-halo
              field_dbl(i,j)=field_dbl(i,halo+1)
            enddo
          enddo
!
!-----------
!***  South
!-----------
!
          do j=dimsize_new(2)-halo+1,dimsize_new(2)
            do i=halo+1,dimsize_new(1)-halo
              field_dbl(i,j)=field_dbl(i,dimsize_new(2)-halo)
            enddo
          enddo
!
!----------
!***  East
!----------
!
          do j=1,dimsize_new(2)
            do i=1,halo
              field_dbl(i,j)=field_dbl(halo+1,j)
            enddo
          enddo
!
!----------
!***  West
!----------
!
          do j=1,dimsize_new(2)
            do i=dimsize_new(1)-halo+1,dimsize_new(1)
              field_dbl(i,j)=field_dbl(dimsize_new(1)-halo,j)
            enddo
          enddo
!
!-----------------------------------------------------------------------
!***  Write the full array including the boundary rows into the
!***  new sfc_data file.
!-----------------------------------------------------------------------
!
          call check(nf90_put_var(ncid_sfc_new,n                        &
                                 ,field_dbl(:,:)                        &
                                 ,start=(/1,1,k/)                       &
                                 ,count=(/dimsize_new(1),dimsize_new(2),1/)))
        enddo
!
      enddo vbls
!
!-----------------------------------------------------------------------
!
      deallocate(dimsize_orig)
      deallocate(dimsize_new)
      deallocate(dimids)
      deallocate(field_dbl)
!
      call check(nf90_close(ncid_sfc_orig))
      call check(nf90_close(ncid_sfc_new))
!
!-----------------------------------------------------------------------
!***  Now create the new grid_spec file with the larger dimensions
!***  and with lats/lons of the boundary's grid cells.
!-----------------------------------------------------------------------
!
!-----------------------------------------------------------------------
!***  Open the original grid_spec file.
!-----------------------------------------------------------------------
!
      call check(nf90_open(filename_grid_spec_orig                      &
                          ,nf90_nowrite                                 &
                          ,ncid_grid_spec_orig))
!
!-----------------------------------------------------------------------
!***  Reproduce the original grid_spec file in an enlarged
!***  version that includes the boundary rows.  Create the new
!***  sfc_data file then add the dimensions, variables, attributes, etc.
!-----------------------------------------------------------------------
!
      call check(nf90_create(filename_grid_spec_new                     &
                           ,nf90_clobber                                &
                           ,ncid_grid_spec_new))
!
!---------------
!*** Dimensions
!---------------
!
      allocate(dimsize_orig(num_dims_grid))
      allocate(dimsize_new(num_dims_grid))
      allocate(dimids(num_dims_grid))
      dimids(:)=0
!
      do n=1,num_dims_grid                                                 !<-- The # of dimensions in the grid_spec file
        call check(nf90_inq_dimid(ncid_grid_spec_orig                   &  !<-- The file ID
                                 ,dimname_grid(n)                       &  !<-- The dimension's name
                                 ,dimid_grid(n)))                          !<-- The dimensions's ID
!
        call check(nf90_inquire_dimension(ncid_grid_spec_orig           &  !<-- The grid_spec file ID
                                         ,dimid_grid(n)                 &  !<-- The dimensions's ID
                                         ,len=dimsize_orig(n)))            !<-- The dimension's value
      enddo
!
      dimsize_new(1)=dimsize_orig(1)+2*halo
      dimsize_new(2)=dimsize_orig(2)+2*halo
      dimsize_new(3)=dimsize_orig(3)
      dimsize_new(4)=dimsize_orig(4)+2*halo
      dimsize_new(5)=dimsize_orig(5)+2*halo
!
      do n=1,num_dims_grid
        call check(nf90_def_dim(ncid_grid_spec_new                      &
                               ,dimname_grid(n)                         &
                               ,dimsize_new(n)                          &
                               ,dimid_grid(n)))
      enddo
!
!---------------
!***  Variables
!---------------
!
      call check(nf90_inquire(ncid_grid_spec_orig,nvariables=nvars))             !<-- The total number of grid_spec file variables
!
      do n=1,nvars
        var_id=n
        call check(nf90_inquire_variable(ncid_grid_spec_orig,var_id,name_var,nctype &  !<-- Name and type of this variable
                  ,ndims,dimids,natts))                                          !<-- # of dimensions and attributes in this variable
!
        call check(nf90_def_var(ncid_grid_spec_new,name_var,nctype,dimids(1:ndims),var_id)) !<-- Define variable in the new grid_spec file.
!
!-----------------------------------------------------------------------
!***  Copy this variable's attributes to the new file's variable.
!-----------------------------------------------------------------------
!
        if(natts>0)then
          do na=1,natts
            call check(nf90_inq_attname(ncid_grid_spec_orig,var_id,na,name_att))       !<-- Get the attribute's name and ID from original
            call check(nf90_copy_att(ncid_grid_spec_orig,var_id,name_att,ncid_sfc_new,var_id))  !<-- Copy to the new grid_spec file
          enddo
        endif
!
      enddo
!
!-----------------------
!***  Global attributes
!-----------------------
!
      call check(nf90_inquire(ncid_grid_spec_orig,nattributes=ngatts))
!
      do n=1,ngatts
        call check(nf90_inq_attname(ncid_grid_spec_orig,NF90_GLOBAL,n,name_att))
        call check(nf90_copy_att(ncid_grid_spec_orig,NF90_GLOBAL,name_att,ncid_grid_spec_new,NF90_GLOBAL))
      enddo
!
!-----------------------------------------------------------------------
!***  We are finished with definitions so put the new enlarged
!***  grid_spec file into data mode.  Also close the original
!***  grid_spec file.
!-----------------------------------------------------------------------
!
      call check(nf90_enddef(ncid_grid_spec_new))
      call check(nf90_close(ncid_grid_spec_orig))
!
!-----------------------------------------------------------------------
!***  The lat/lon values in the original grid_spec file are the same 
!***  as the interior values in the grid file from the pre-processing.
!***  Therefore rather than transfer values from the original 
!***  grid_spec file and then fill in the boundary rows simply take
!***  all values for the new file from the pre-processed grid file.
!-----------------------------------------------------------------------
!
      call check(nf90_open(filename_grid_tile                           &
                          ,nf90_nowrite                                 &
                          ,ncid_grid_tile))       
!
!-----------------------------------------------------------------------
!***  First fill in the grid cell counts in the new file.  They are
!***  the first variables in the file.  Variable 3 (time) is set to 0.
!-----------------------------------------------------------------------
!
      do n=1,num_dims_grid
        if(n==3)then
          call check(nf90_put_var(ncid_grid_spec_new,n                  &
                                 ,zero                                  &
                                 ,start=(/1/)))
        else
          allocate(grid_point_count(1:dimsize_new(n)))
          do nd=1,dimsize_new(n)
            grid_point_count(nd)=nd
          enddo
!
          call check(nf90_put_var(ncid_grid_spec_new,n                  &
                                 ,grid_point_count(:)                   &
                                 ,start=(/1/)                           &
                                 ,count=(/dimsize_new(n)/)))
!
          deallocate(grid_point_count)
        endif
      enddo
!
!-----------------------------------------------------------------------
!***  Fill latitude and longitude arrays with values extracted from
!***  appropriate locations on the super grid in the grid tile file
!***  and put them into the new grid_spec file.
!-----------------------------------------------------------------------
!
      allocate(field(1:dimsize_new(1),1:dimsize_new(2)))
!
!------------------------------------
!***  Longitude of grid cell corners
!------------------------------------
!
      call check(nf90_inq_varid(ncid_grid_tile,'x',var_id))                !<-- Get var ID for super grid longitude ('x')
!
      call check(nf90_get_var(ncid_grid_tile,var_id                     &
                             ,field(:,:)                                &
                             ,start=(/1,1/)                             &
                             ,stride=(/2,2/) ) )
!
      call check(nf90_inq_varid(ncid_grid_spec_new,'grid_lon',var_id))     !<-- Get var ID for corner longitudes '(grid_lon')
!
      call check(nf90_put_var(ncid_grid_spec_new,var_id                 &
                             ,field(:,:)                                &
                             ,start=(/1,1/)                             &
                             ,count=(/dimsize_new(1),dimsize_new(2)/)))
!
!-----------------------------------
!***  Latitude of grid cell corners
!-----------------------------------
!
      call check(nf90_inq_varid(ncid_grid_tile,'y',var_id))                !<-- Get var ID for super grid latitude ('y')
!
      call check(nf90_get_var(ncid_grid_tile,var_id                     &
                             ,field(:,:)                                &
                             ,start=(/1,1/)                             &
                             ,stride=(/2,2/) ) )
!
      call check(nf90_inq_varid(ncid_grid_spec_new,'grid_lat',var_id))     !<-- Get var ID for corner latitudes '(grid_lat')
!
      call check(nf90_put_var(ncid_grid_spec_new,var_id                 &
                             ,field(:,:)                                &
                             ,start=(/1,1/)                             &
                             ,count=(/dimsize_new(1),dimsize_new(2)/)))
!
      deallocate(field)
      allocate(field(dimsize_new(4),dimsize_new(5)))
!
!------------------------------------
!***  Longitude of grid cell centers
!------------------------------------
!
      call check(nf90_inq_varid(ncid_grid_tile,'x',var_id))                !<-- Get var ID for super grid longitude ('x')
!
      call check(nf90_get_var(ncid_grid_tile,var_id                     &
                             ,field(:,:)                                &
                             ,start=(/2,2/)                             &
                             ,stride=(/2,2/) ) )
!
      call check(nf90_inq_varid(ncid_grid_spec_new,'grid_lont',var_id))    !<-- Get var ID for center longitudes '(grid_lont')
!
      call check(nf90_put_var(ncid_grid_spec_new,var_id                 &
                             ,field(:,:)                                &
                             ,start=(/1,1/)                             &
                             ,count=(/dimsize_new(4),dimsize_new(5)/)))
!
!-----------------------------------
!***  Latitude of grid cell centers
!-----------------------------------
!
      call check(nf90_inq_varid(ncid_grid_tile,'y',var_id))                !<-- Get var ID for super grid latitude ('y')
!
      call check(nf90_get_var(ncid_grid_tile,var_id                     &
                             ,field(:,:)                                &
                             ,start=(/2,2/)                             &
                             ,stride=(/2,2/) ) )
!
      call check(nf90_inq_varid(ncid_grid_spec_new,'grid_latt',var_id))    !<-- Get var ID for center latitudes '(grid_latt')
!
      call check(nf90_put_var(ncid_grid_spec_new,var_id                 &
                             ,field(:,:)                                &
                             ,start=(/1,1/)                             &
                             ,count=(/dimsize_new(4),dimsize_new(5)/)))
!
      deallocate(field)
!
      call check(nf90_close(ncid_grid_spec_new))
      call check(nf90_close(ncid_grid_tile))
!
!-----------------------------------------------------------------------
      contains
!-----------------------------------------------------------------------
!
      subroutine check(status)
!
      integer,intent(in) :: status
!
      if(status /= nf90_noerr) then
        print *, trim(nf90_strerror(status))
        stop "Stopped"
      end if
!
      end subroutine check
!
!-----------------------------------------------------------------------
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!-----------------------------------------------------------------------
!
      end program prep_for_regional_DA
!
!---------------------------------------------------------------------

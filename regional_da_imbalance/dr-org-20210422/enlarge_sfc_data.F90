!-----------------------------------------------------------------------
      program enlarge_sfc_data
!-----------------------------------------------------------------------
!***  When the regional DA includes boundary rows in the core and 
!***  tracer restart files it will also need those rows in the
!***  sfc_data.nc file.  It is sufficient to simply extend the 
!***  outermost values from the integration domain into the 
!***  boundary rows.
!-----------------------------------------------------------------------
      use netcdf
!-----------------------------------------------------------------------
      implicit none
!-----------------------------------------------------------------------
!
      integer,parameter :: double=selected_real_kind(p=13,r=200)           !<-- Define KIND for double precision real
!
      integer,parameter :: num_dims_sfc=4
      integer,parameter :: halo=3
!
      integer :: i,iend_new,istart_new,j,jend_new,jstart_new,k,kend
!
      integer :: n,na,natts,ndims,nctype,ngatts,nvars,var_id
!
      integer :: ncid_sfc_new,ncid_sfc_orig
!
      integer,dimension(1:num_dims_sfc) :: dimids=(/0,0,0,0/)
!
      integer,dimension(num_dims_sfc) :: dimid_sfc                      &
                                        ,dimsize_new                    &
                                        ,dimsize_orig
!
      real(kind=double),dimension(:,:),allocatable :: field
!
      character(len=50) :: name_att,name_var
!
      character(len=20) :: filename_sfc_data_orig='sfc_data_orig.nc'    &  !<-- The original standard-sized sfc_data.nc file
                          ,filename_sfc_data_new='sfc_data.nc'             !<-- The same file but with data in the boundary rows
!
      character(len=20),dimension(num_dims_sfc) :: dimname_sfc=(/          &
                                                                 'xaxis_1' &
                                                                ,'yaxis_1' &
                                                                ,'zaxis_1' &
                                                                ,'Time'    &
                                                                /)
!
!-----------------------------------------------------------------------
!***********************************************************************
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
      dimsize_new(2)=dimsize_orig(2)+2*halo
      dimsize_new(3)=dimsize_orig(3)
!
      call check(nf90_def_dim(ncid_sfc_new,dimname_sfc(1),dimsize_new(1),dimid_sfc(1)))
      call check(nf90_def_dim(ncid_sfc_new,dimname_sfc(2),dimsize_new(2),dimid_sfc(2)))
      call check(nf90_def_dim(ncid_sfc_new,dimname_sfc(3),dimsize_new(3),dimid_sfc(3)))
      call check(nf90_def_dim(ncid_sfc_new,'Time',NF90_UNLIMITED,dimid_sfc(4)))
!
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
        call check(nf90_def_var(ncid_sfc_new,name_var,nctype,dimids(1:ndims),var_id)) !<-- Define the variable in the new sfc file.
!
!-----------------------------------------------------------------------
!***  Copy this variable's attributes to the new file's variable.
!-----------------------------------------------------------------------
!
        if(natts>0)then
          do na=1,natts
            call check(nf90_inq_attname(ncid_sfc_orig,var_id,na,name_att))                !<-- Get the attribute's name and ID from original
            call check(nf90_copy_att(ncid_sfc_orig,var_id,name_att,ncid_sfc_new,var_id))  !<-- Copy to the new sfc_data dile
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
!***  dimensions.  Read each field into an array the size of the
!***  enlarged domain.
!-----------------------------------------------------------------------
!
      allocate(field(1:dimsize_new(1),1:dimsize_new(2)))
      field(:,:)=9.e9
!
      istart_new=halo+1                                                    !<--
      iend_new=dimsize_orig(1)+halo                                        !  The index limits of the original
      jstart_new=halo+1                                                    !  data in the enlarged domain.
      jend_new=dimsize_orig(2)+halo                                        !<--
!
      do n=num_dims_sfc+1,nvars
!
        call check(nf90_inquire_variable(ncid_sfc_orig,n,ndims=ndims))
!
!       call check(nf90_inquire_variable(ncid_sfc_orig,n,name=name_var))
!       write(0,*)' for var #',n,' name=',trim(name_var),'  ndims=',ndims
!
        kend=1
        if(ndims==4)then
          kend=dimsize_new(3)
        endif
!
!       write(0,*)' istart_new=',istart_new,' iend_new=',iend_new,' jstart_new=',jstart_new,' jend_new=',jend_new
!       write(0,*)' dimsize_orig(1)=',dimsize_orig(1),' dimsize_orig(2)=',dimsize_orig(2)
!       write(0,*)' kend=',kend
        do k=1,kend
          call check(nf90_get_var(ncid_sfc_orig,n                       &
                    ,field(istart_new:iend_new,jstart_new:jend_new)     &  !<-- The full field array with BC rows for layer k
                    ,start=(/1,1,k/)                                    &
                    ,count=(/dimsize_orig(1),dimsize_orig(2),1/)))
!
!-----------------------------------------------------------------------
!***  Fill in the boundary rows with the values from the outer
!***  integration row.  Finesse the corners sincec this is not 
!*** critical for the corners.
!-----------------------------------------------------------------------
!
!-----------
!***  North
!-----------
!
      do j=1,halo
        do i=halo+1,dimsize_new(1)-halo
          field(i,j)=field(i,halo+1)
        enddo
      enddo
!
!-----------
!***  South
!-----------
!
      do j=dimsize_new(2)-halo+1,dimsize_new(2)
        do i=halo+1,dimsize_new(1)-halo
          field(i,j)=field(i,dimsize_new(2)-halo)
        enddo
      enddo
!
!----------
!***  East
!----------
!
      do j=1,dimsize_new(2)
        do i=1,halo
          field(i,j)=field(halo+1,j)
        enddo
      enddo
!
!----------
!***  West
!----------
!
      do j=1,dimsize_new(2)
        do i=dimsize_new(1)-halo+1,dimsize_new(1)
          field(i,j)=field(dimsize_new(1)-halo,j)
        enddo
      enddo
!
!-----------------------------------------------------------------------
!***  Write the interior data to the new file.
!-----------------------------------------------------------------------
!
          call check(nf90_put_var(ncid_sfc_new,n                        &
                                 ,field(:,:)                            &
                                 ,start=(/1,1,k/)                       &
                                 ,count=(/dimsize_new(1),dimsize_new(2),1/)))
!         write(0,*)' after put_var for ',trim(name_var)
!         write(0,*)' '
        enddo
!
      enddo
!
!-----------------------------------------------------------------------
!
      call check(nf90_close(ncid_sfc_orig))
      call check(nf90_close(ncid_sfc_new))
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
      end program enlarge_sfc_data
!
!---------------------------------------------------------------------

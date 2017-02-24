!  readGLDASPar.f90 
!
!  FUNCTIONS:
!  readGLDASPar - Entry point of console application.
!

!****************************************************************************
!
!  PROGRAM: readGLDASPar
!
!  PURPOSE:  Entry point for the console application.
!
!****************************************************************************

    program readGLDASPar

    implicit none

    integer,parameter :: nx=360, ny=150
    real,dimension(nx,ny) :: mask, domveg, soils
     character(len=20) :: fname
    
    open(98,file='Y:\GLDAS\Parameter\landmask_mod44w_10.1gd4r',&
        form='unformatted',status='old', &
        access='direct',recl=nx*ny*4)
    read(98,rec=1) mask
    close(98)
    
    open(98,file='Y:\GLDAS\Parameter\modmodis_domveg20_1.0.bin',&
        form='unformatted',status='old', &
        access='direct',recl=nx*ny*4)
    read(98,rec=1) domveg
    close(98)
    
     open(98,file='Y:\GLDAS\Parameter\tex_statsfao_mod44w.1gd4r',form='unformatted',status='old', &
          access='direct',recl=nx*ny*4)
     read(98,rec=1) soils
     close(98)
    
    close(98)
    
    
    
    end program readGLDASPar


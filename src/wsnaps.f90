! $Id: wsnaps.f90,v 1.1 2002-06-12 09:46:03 brandenb Exp $

!!!!!!!!!!!!!!!!!!!!!!!
!!!   wsnaps.f90   !!!
!!!!!!!!!!!!!!!!!!!!!!!

!!!  Distributed IO (i.e. each process writes its own file tmp/procX)
!!!  07-Nov-2001/wd: Put into separate module, so one can choose
!!!  alternative IO mechanism.

module Wsnaps

  implicit none

contains

!***********************************************************************
    subroutine wsnap(chsnap,a,llabel)
!
!  Write snapshot file, labelled consecutively if llabel==.true.
!  Otherwise just write a snapshot without label (used for restart files)
!
!  30-sep-97/axel: coded
!
      use Cdata
      use Mpicomm
      use Boundcond
      use Sub
      use Io
!
      real, dimension (mx,my,mz,mvar) :: a
      character (len=4) :: ch
      character (len=9) :: file
      character (len=*) :: chsnap
      character (len=160) :: errmesg
      logical lsnap,llabel
      integer, save :: ifirst,nsnap
      real, save :: tsnap
!
!  Output snapshot with label in 'tsnap' time intervals
!  file keeps the information about number and time of last snapshot
!
      if (llabel) then
        file='tsnap.dat'
!
!  at first call, need to initialize tsnap
!  tsnap calculated in out1, but only available to root processor
!
        if (ifirst==0) then
          call out1 (file,tsnap,nsnap,dsnap,t)
          ifirst=1
        endif
!
!  Check whether we want to output snapshot. If so, then
!  update ghost zones for var.dat (cheap, since done infrequently)
!
        call out2 (file,tsnap,nsnap,dsnap,t,lsnap,ch,.true.)
        if (lsnap) then
          call initiate_isendrcv_bdry(a)
          call boundconds(a,errmesg); if (errmesg/="") call stop_it(trim(errmesg))
          call finalise_isendrcv_bdry(a)
          call output(chsnap//ch,a,mvar)
        endif
!
!  write snapshot without label
!
      else
        call initiate_isendrcv_bdry(a)
        call boundconds(a,errmesg); if (errmesg/="") call stop_it(trim(errmesg))
        call finalise_isendrcv_bdry(a)
        call output(chsnap,a,mvar)
      endif
!
    endsubroutine wsnap
!***********************************************************************

endmodule Wsnaps

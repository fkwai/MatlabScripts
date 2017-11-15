#include "fintrf.h"
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      
      IMPLICIT NONE
      mwpointer :: plhs(*), prhs(*)
      mwpointer :: mxGetPr
      mwPointer :: pm
      mwPointer :: mxGetField, mxGetDimensions, mxGetM, mxGetN
      mwpointer :: px,py,xx,yy,inout
      Integer :: nlhs, nrhs, I, nx, m(3), ntype,mG(4)
      real*8 :: nzz, LVL,nGho(3)
      
      
      xx = mxGetPr(prhs(1))
      yy = mxGetPr(prhs(2))
      px = mxGetPr(prhs(3))
      py = mxGetPr(prhs(4))
      inout = mxGetPr(prhs(5))
      CALL mxCopyPtrToInteger4(mxGetDimensions(prhs(1)),m,3)
      nx = m(1)*m(2)
      CALL mxCopyPtrToInteger4(mxGetDimensions(prhs(3)),m,3)
      
      CALL PNPOLY(m(1),m(2),%val(px),%val(py),%val(xx),%val(yy),              &
     &    nx,%val(inout))
      
      end subroutine

      SUBROUTINE PNPOLY(ky,kx,PXX,PYY,XX,YY,N,INOUTT)            
      ! decide if a point (PXX,PYY) is within a polygon (XX,YY)       
      INTEGER ky,kx,N
      REAL*8 X(N),Y(N),XX(N),YY(N)
      REAL*8,DIMENSION(ky,kx)::PXX,PYY
      INTEGER INOUTT(ky,kx)                        
      LOGICAL MX,MY,NX,NY                                               
      REAL*8 PX,PY
      INTEGER O, II,JJ
      DO II = 1,ky
         DO JJ = 1,kx
           PX = PXX(II,JJ)
           PY = PYY(II,JJ)
      
      ! BEGIN ORIGINAL SUBROUTINE ########################                                           
6     DO 1 I=1,N                                                        
      X(I)=XX(I)-PX                                                     
1     Y(I)=YY(I)-PY                                                     
      INOUT=-1                                                          
      DO 2 I=1,N                                                        
      J=1+MOD(I,N)                                                      
      MX=X(I).GE.0.0                                                    
      NX=X(J).GE.0.0                                                    
      MY=Y(I).GE.0.0                                                    
      NY=Y(J).GE.0.0                                                    
      IF(.NOT.((MY.OR.NY).AND.(MX.OR.NX)).OR.(MX.AND.NX)) GO TO 2       
      IF(.NOT.(MY.AND.NY.AND.(MX.OR.NX).AND..NOT.(MX.AND.NX))) GO TO 3  
      INOUT=-INOUT                                                      
      GO TO 2                                                           
3     IF((Y(I)*X(J)-X(I)*Y(J))/(X(J)-X(I))) 2,4,5                       
4     INOUT=0                                                           
      EXIT                                                            
5     INOUT=-INOUT                                                      
2     CONTINUE    
      ! END ORIGINAL SUBROUTINE ########################   
         
         INOUTT(II,JJ)=INOUT
         ENDDO
      ENDDO
                                                      
      RETURN                                                            
      END    
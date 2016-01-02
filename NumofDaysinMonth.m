function [ ndayG ] = NumofDaysinMonth( t,ny,nx )
% return a 3D matrix of num of days in month. 

% t: yyyymm
% ny, nx: returned matrix size. 

Y=floor(t/100);M=t-Y*100;
nday=eomday(Y,M);
ndayZ=reshape(nday,1,1,length(nday));
ndayG=repmat(ndayZ,ny,nx);

end


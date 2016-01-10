load('Y:\TRMM\TRMM.mat')
xq=0.5:359.5;
yq=49.5:-1:-49.5;
z=1:length(t);
[xqm,yqm,zqm]=meshgrid(xq,yq,z);
[xm,ym,zm]=meshgrid(lon,lat,z);

zq=interp3(xm,ym,zm,TRMM,xqm,yqm,zqm);
TRMM_res=zq;
x=xq;y=yq;
save Y:\TRMM\TRMM_res TRMM_res x y t

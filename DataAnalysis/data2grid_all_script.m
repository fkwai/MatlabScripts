crdNA=load('crd_NA.mat');

%GRACE
graceData=load('grace_global.mat');
graceData.DATA(abs(graceData.DATA)>1000)=nan;
xx=graceData.LOCATIONS(1,:);
yy=graceData.LOCATIONS(2,:);
xx(xx>180)=xx(xx>180)-360;
graceGrid=data2grid3d(graceData.DATA',xx,yy,1);
t=graceData.T;
x=sort(unique(xx));
y=sort(unique(yy),'descend');
indx=find(x<=max(crdNA.x)&x>=min(crdNA.x));
indy=find(y<=max(crdNA.y)&y>=min(crdNA.y));
x=x(indx);
y=y(indy);
graceGrid=graceGrid(indy,indx,:);
save graceGrid graceGrid t x y

%NLDAS
nldasData.EVP=load('EVP.mat');
nldasData.PEVPR=load('PEVPR.mat');
nldasData.ARAIN=load('ARAIN.mat');
nldasData.ASNOW=load('ASNOW.mat');
x=nldasData.EVP.crd(:,1);
y=nldasData.EVP.crd(:,2);
EVPgrid=data2grid3d(nldasData.EVP.EVP,x,y,1/8);
PEVPRgrid=data2grid3d(nldasData.PEVPR.PEVPR,x,y,1/8);
ARAINgrid=data2grid3d(nldasData.ARAIN.ARAIN,x,y,1/8);
ASNOWgrid=data2grid3d(nldasData.ASNOW.ASNOW,x,y,1/8);
x=sort(unique(nldasData.EVP.crd(:,1)));
y=sort(unique(nldasData.EVP.crd(:,2)),'descend');
t=nldasData.EVP.t;
save nldasGridF EVPgrid PEVPRgrid ARAINgrid ASNOWgrid x y t

%upscale NLDAS
[EVPgridC,x,y]=upscaleNLDAS(EVPgrid);
[PEVPRgridC,x,y]=upscaleNLDAS(PEVPRgrid);
[ARAINgridC,x,y]=upscaleNLDAS(ARAINgrid);
[ASNOWgridC,x,y]=upscaleNLDAS(ASNOWgrid);
save nldasGridC EVPgridC PEVPRgridC ARAINgridC ASNOWgridC x y t
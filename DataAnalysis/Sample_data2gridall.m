%this script will transfer raw GRACE and NLDAS data into 3D grid


%GRACE
crdNA=load('crd_GRACE.mat');
graceData=load('E:\work\GRACE\grace_global_CSR.mat');
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
save GRACE/graceGrid.mat graceGrid t x y

%NLDAS
nldasData.EVP=load('NLDAS\EVP.mat');
nldasData.PEVPR=load('NLDAS\PEVPR.mat');
nldasData.ARAIN=load('NLDAS\ARAIN.mat');
nldasData.ASNOW=load('NLDAS\ASNOW.mat');
nldasData.SNOM=load('NLDAS\SNOM.mat');
x=nldasData.EVP.crd(:,1);
y=nldasData.EVP.crd(:,2);
EVPgrid=data2grid3d(nldasData.EVP.EVP,x,y,1/8);
PEVPRgrid=data2grid3d(nldasData.PEVPR.PEVPR,x,y,1/8);
ARAINgrid=data2grid3d(nldasData.ARAIN.ARAIN,x,y,1/8);
ASNOWgrid=data2grid3d(nldasData.ASNOW.ASNOW,x,y,1/8);
SNOMgrid=data2grid3d(nldasData.SNOM.SNOM,x,y,1/8);
x=sort(unique(nldasData.EVP.crd(:,1)));
y=sort(unique(nldasData.EVP.crd(:,2)),'descend');
t=nldasData.EVP.t;
save NLDAS\nldasGridF EVPgrid PEVPRgrid ARAINgrid ASNOWgrid SNOMgrid x y t

%upscale NLDAS
[EVPgridC,x,y]=upscaleNLDAS(EVPgrid);
[PEVPRgridC,x,y]=upscaleNLDAS(PEVPRgrid);
[ARAINgridC,x,y]=upscaleNLDAS(ARAINgrid);
[ASNOWgridC,x,y]=upscaleNLDAS(ASNOWgrid);
save NLDAS\nldasGridC EVPgridC PEVPRgridC ARAINgridC ASNOWgridC x y t
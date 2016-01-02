function HUCstr = rET_calculate_monthly( demfile,FORAfolder,NOAHfolder,maskfile,HUCstr,HUCstr_t )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% demfile='E:\work\DataAnaly\global_dem\dem.mat';
% FORAfolder='E:\work\MOPEX\FORA';
% NOAHfolder='E:\work\MOPEX\NOAH';
% maskfile='E:\work\MOPEX\script\mask_MOPEX_daily_32.mat';

load(demfile);
load([NOAHfolder,'\NSWRS.mat']);
load([NOAHfolder,'\NLWRS.mat']);
tNOAH=t;
load([FORAfolder,'\TMP.mat']);
load([FORAfolder,'\SPFH.mat']);
load([FORAfolder,'\PRES.mat']);
load([FORAfolder,'\UGRD.mat']);
load([FORAfolder,'\VGRD.mat']);
load([FORAfolder,'\PEVAP.mat']);
tFORA=t;

[C,iNOAH,iFORA]=intersect(tNOAH,tFORA);
t=tFORA(iFORA);


NSWRSgrid = data2grid3d( NSWRS(:,iNOAH),crd(:,1),crd(:,2),1/8 );
NLWRSgrid = data2grid3d( NLWRS(:,iNOAH),crd(:,1),crd(:,2),1/8 );
TMPgrid = data2grid3d( TMP(:,iFORA),crd(:,1),crd(:,2),1/8 );
SPFHgrid = data2grid3d( SPFH(:,iFORA),crd(:,1),crd(:,2),1/8 );
PRESgrid = data2grid3d( PRES(:,iFORA),crd(:,1),crd(:,2),1/8 );
UGRDgrid = data2grid3d( UGRD(:,iFORA),crd(:,1),crd(:,2),1/8 );
VGRDgrid = data2grid3d( VGRD(:,iFORA),crd(:,1),crd(:,2),1/8 );
PEVAPgrid = data2grid3d( PEVAP(:,iFORA),crd(:,1),crd(:,2),1/8 );

Rad=NSWRSgrid.*0.0864 + NLWRSgrid* 0.0864;
% http://earthscience.stackexchange.com/questions/2360/how-do-i-convert-specific-humidity-to-relative-humidity
Hmd=0.263.*SPFHgrid.*PRESgrid./exp((17.67.*TMPgrid)./(TMPgrid+243.51))/100;
e0 = (exp((16.78.*TMPgrid-116.9)./(TMPgrid+237.3)));
Wnd=sqrt(UGRDgrid.^2+VGRDgrid.^2);
T=TMPgrid;
Elev=repmat(dem,[1,1,length(iNOAH)]);
tau=0;
ref=0;

[rET,rETs,Rn,Hb,Hli]=PenmanMonteith(Rad,Hmd,e0,Wnd,T,Elev,tau,ref,1);

t=tFORA(iFORA);
save rET_new.mat rET rETs Rn Hb Hli PEVAPgrid t

[ny,nx,nz]=size(rET);
nday=zeros(1,1,nz);
nday(1,1,:)=eomday(floor(t/100),t-floor(t/100)*100);
nday=repmat(nday,[ny,nx,1]);

mask_nldas=load(maskfile);
mask_nldas=mask_nldas.mask;
nldasT=datenum(num2str(t),'yyyymm');

HUCstr = grid2HUC( 'rET',rET.*nday,nldasT,mask_nldas,HUCstr,HUCstr_t);
HUCstr = grid2HUC( 'rETs',rETs.*nday,nldasT,mask_nldas,HUCstr,HUCstr_t);

end


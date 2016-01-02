clear all
E_JBF_data=load('E:\work\DataAnaly\ET_JBF\AET_JBF_10deg.mat');
GRACE_data=load('E:\work\GRACE\graceGrid_CSR.mat');
% E_CLM_data=load('E:\work\LDAS\GLDAS_matfile\NOAH_V2\Evap.mat');
% Ep_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Evap_3D.mat');
% SWdown_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\SWdown_3D.mat');
% LWdown_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\LWdown_3D.mat');
% PSurf_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\PSurf_3D.mat');
% Qair_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Qair_3D.mat');
% Tair_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Tair_3D.mat');
% Wind_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Wind_3D.mat');
% Snowf_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Snowf_3D.mat');
% Rainf_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Rainf_3D.mat');
% Qs_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Qs_3D.mat');
% Qsb_CLM_data=load('E:\work\LDAS\R_NLDAS\Matfile_GLDAS_3D\CLM\Qsb_3D.mat');
Tair_GLDAS_data=load('E:\work\LDAS\GLDAS_matfile\NOAH_V2\Tair.mat');
E_GLDAS_data=load('E:\work\LDAS\GLDAS_matfile\NOAH_V2\Evap.mat');
Snowf_GLDAS_data=load('E:\work\LDAS\GLDAS_matfile\NOAH_V2\Snowf.mat');
Rainf_GLDAS_data=load('E:\work\LDAS\GLDAS_matfile\NOAH_V2\Rainf.mat');
Qs_GLDAS_data=load('E:\work\LDAS\GLDAS_matfile\NOAH_V2\Qs.mat');
Qsb_GLDAS_data=load('E:\work\LDAS\GLDAS_matfile\NOAH_V2\Qsb.mat');
dem_data=load('E:\work\DataAnaly\dem_GLDAS.mat');
GRDC_data=load('E:\work\data\GRDC_UNH\GRDC.mat');
TRMM_data=load('E:\work\paws\scripts\KF\PAWS_global_data\TRMM_res.mat');

tGLDAS=E_GLDAS_data.t;
tJBF=E_JBF_data.tym;
tGRACE=GRACE_data.t;
tGRACE=str2num(datestr(tGRACE,'yyyymm'));
tTRMM=TRMM_data.t;

% %calculate rET
% SWdowngrid=SWdown_CLM_data.SWdown_3D;
% LWdowngrid=LWdown_CLM_data.LWdown_3D;
% PSurfgrid=PSurf_CLM_data.PSurf_3D;
% Qairgrid=Qair_CLM_data.Qair_3D;
% Tairgrid=Tair_CLM_data.Tair_3D;
% Windgrid=Wind_CLM_data.Wind_3D;
% dem=dem_data.dem_GLDAS;
% Rad=SWdowngrid.*0.0864 + LWdowngrid* 0.0864;
% % http://earthscience.stackexchange.com/questions/2360/how-do-i-convert-specific-humidity-to-relative-humidity
% Hmd=0.263.*Qairgrid.*PSurfgrid./exp((17.67.*Tairgrid)./(Tairgrid+243.51))/100;
% e0 = (exp((16.78.*Tairgrid-116.9)./(Tairgrid+237.3)));
% Wnd=Windgrid;
% T=Tairgrid;
% Elev=repmat(dem,[1,1,length(tCLM)]);
% tau=0;
% ref=1;
% [rET,rETs,Rn,Hb,Hli]=PenmanMonteith(Rad,Hmd,e0,Wnd,T,Elev,tau,ref,1);
% t=tCLM;x=E_CLM_data.x;y=E_CLM_data.y;
% save rET_GLDAS_3d rET t x y
load('E:\work\DataAnaly\rET_GLDAS_v2')
trET=t;

%GLDAS data to grid
x=E_GLDAS_data.crd(:,1);
y=E_GLDAS_data.crd(:,2);
[E_GLDAS_grid_all,xG,yG]=data2grid3d(E_GLDAS_data.Evap,x,y,1);
rainfgrid=data2grid3d(Rainf_GLDAS_data.Rainf,x,y,1);
snowfgrid=data2grid3d(Snowf_GLDAS_data.Snowf,x,y,1);
P_GLDAS_grid_all=snowfgrid+rainfgrid;
[Tair_GLDAS_grid,xG,yG]=data2grid3d(Tair_GLDAS_data.Tair,x,y,1);

% generate common mask and date that works for GRACE, GLDAS and JBF_ET
maskGLDAS=~isnan(E_GLDAS_grid_all(:,:,1));
maskGLDAS(151:180,:)=0;
maskJBF=(E_JBF_data.E_JBF(:,:,1))~=-99;
maskGRACE=abs(GRACE_data.graceGrid_CSR(:,:,1))<100;
maskGRDC=~isnan(GRDC_data.GRDC.Q);
maskTRMM=ones(180,360)*nan;
maskTRMM(41:140,:)=1;
mask=maskGLDAS.*maskJBF.*maskGRACE.*maskTRMM;
%mask=maskGLDAS.*maskJBF.*maskGRACE.*maskGRDC;   %use GRDC
mask(mask==0)=nan;

sd=200210;%common t
ed=200610;
d1=datenum(num2str(sd),'yyyymm');
d2=datenum(num2str(ed),'yyyymm');
t=unique(str2num(datestr([d1:d2],'yyyymm')));
sd=200210;% GRACE amp t
ed=201409;
d1=datenum(num2str(sd),'yyyymm');
d2=datenum(num2str(ed),'yyyymm');
tGRACE_comp=unique(str2num(datestr([d1:d2],'yyyymm')));
[C,indJBF,iJBF]=intersect(t,tJBF);
[C,indCLM,iGLDAS]=intersect(t,tGLDAS);
[C,indrET,irET]=intersect(t,trET);
[C,indTRMM,iTRMM]=intersect(t,tTRMM);
[C,indGRACE,iGRACE]=intersect(tGRACE_comp,tGRACE);
Y=floor(t/100);M=t-Y*100;
nday=eomday(Y,M);
ndayZ=reshape(nday,1,1,length(nday));
ndayG_CLM=repmat(ndayZ,150,360);
ndayG=repmat(ndayZ,180,360);

%generate globle map of E_JBL, E_CLM, Ep_CLM, P_CLM, Amp_fft, Q_GRDC
TGLDASgrid=Tair_GLDAS_grid(:,:,iGLDAS);
TGLDASgrid(151:180,:,:)=nan;
E_JBF_grid=wm2mmPerMonth(E_JBF_data.E_JBF(:,:,iJBF),TGLDASgrid,ndayG)*12;
E_JBF=mean(E_JBF_grid,3).*mask;

E_GLDAS_grid=E_GLDAS_grid_all(:,:,iGLDAS).*ndayG_CLM*60*60*24*12;
E_GLDAS_grid(151:180,:,:)=nan;
E_GLDAS=mean(E_GLDAS_grid,3);
E_GLDAS=E_GLDAS.*mask;

P_GLDAS_grid=P_GLDAS_grid_all(:,:,iGLDAS).*ndayG_CLM*60*60*24*12;
P_GLDAS_grid(151:180,:,:)=nan;
P_GLDAS=mean(P_GLDAS_grid,3);
P_GLDAS=P_GLDAS.*mask;

Ep_GLDAS_grid=rET(:,:,irET).*ndayG_CLM*12;
Ep_GLDAS_grid(151:180,:,:)=nan;
Ep_GLDAS=mean(Ep_GLDAS_grid,3);
Ep_GLDAS=Ep_GLDAS.*mask;

P_TRMM_grid(41:140,:,:)=TRMM_data.TRMM_res(:,:,iTRMM)*12;
P_TRMM_grid(141:180,:,:)=nan;
P_TRMM_grid(1:40)=nan;
P_TRMM_grid=[P_TRMM_grid(:,181:360,:),P_TRMM_grid(:,1:180,:)];
P_TRMM=mean(P_TRMM_grid,3).*mask;

% % longer term average
% Y=floor(tGLDAS/100);M=tGLDAS-Y*100;
% nday_long=eomday(Y,M);
% ndayZ_long=reshape(nday_long,1,1,length(nday_long));
% ndayG_long=repmat(ndayZ_long,150,360);
% 
% E_GLDAS_grid_long=E_GLDAS_grid_all(:,:,:).*ndayG_long*60*60*24*12;
% E_GLDAS_grid_long(151:180,:,:)=nan;
% E_GLDAS_long=mean(E_GLDAS_grid_long,3);
% E_GLDAS_long=E_GLDAS_long.*mask;
% 
% P_GLDAS_grid_long=P_GLDAS_grid_all(:,:,:).*ndayG_long*60*60*24*12;
% P_GLDAS_grid_long(151:180,:,:)=nan;
% P_GLDAS_long=mean(P_GLDAS_grid_long,3);
% P_GLDAS_long=P_GLDAS_long.*mask;
% 
% Ep_GLDAS_grid_long=rET(:,:,:).*ndayG_long*12;
% Ep_GLDAS_grid_long(151:180,:,:)=nan;
% Ep_GLDAS_long=mean(Ep_GLDAS_grid_long,3);
% Ep_GLDAS_long=Ep_GLDAS_long.*mask;

% CGIAR-CSI Global-PET
Epfile='E:\work\data\PET_he_annual\pet_he_yr_1deg.tif';
[dd, info] = geotiffread(Epfile);
Ep_CGIAR=double(dd);
Ep_CGIAR(151:180,:)=0;
Ep_CGIAR(Ep_CGIAR==0)=nan;

%Q_GRDC=GRDC_data.GRDC.Q.*mask; %use GRDC

%calculate amplitude
tempS=zeros(length(tGRACE_comp),1);
Amp_fft=zeros(180,360);Amp_0=zeros(180,360);Amp_fft_noband=zeros(180,360);
Acf_dtr48=zeros(180,360);Pcf2_dtr48=zeros(180,360);Pcf3_dtr48=zeros(180,360);
Acf_dtr72=zeros(180,360);Pcf2_dtr72=zeros(180,360);Pcf3_dtr72=zeros(180,360);
for j=1:180
    for i=1:360
        if ~isnan(mask(j,i))            
            tempS=tempS*nan;
            tempS(indGRACE)=GRACE_data.graceGrid_CSR(j,i,iGRACE);
            ind=find(~isnan(tempS));
            indn=find(isnan(tempS));
            s0=tempS(ind);
            t0=tGRACE_comp(ind);
            tq=tGRACE_comp(indn);          
            sq = interp1(t0,s0,tq,'spline');
            tempS(indn)=sq;
            tempS=tempS.*10;%cm to mm
            [maxAmp,f,scales,AmpS]=fftBandAmplitude(tempS,12,[2/3, 5/3]);            
            Amp_fft(j,i)=maxAmp;
            [maxAmp,f,scales,AmpS]=fftBandAmplitude(tempS,12);            
            Amp_fft_noband(j,i)=maxAmp;
            
            ts.t=datenum(num2str(tGRACE_comp),'yyyymm');
            ts.v=tempS;
            [Amp,AvgAmp,StdAmp]=ts2Amp( ts,20021001,20141001,0,1001 );
            Amp_0(j,i)=AvgAmp;
            
            [sfit,RMS] = detrendMFDFA(tempS,[48,72],0);
            temp=autocorr(sfit(:,1),1);
            Acf_dtr48(j,i)=temp(2);
            temp=parcorr(sfit(:,1),12);
            Pcf2_dtr48(j,i)=temp(3);
            Pcf3_dtr48(j,i)=temp(4);

            temp=autocorr(sfit(:,2),1);
            Acf_dtr72(j,i)=temp(2);
            temp=parcorr(sfit(:,2),12);
            Pcf2_dtr72(j,i)=temp(3);
            Pcf3_dtr72(j,i)=temp(4);
        end
    end
end
GRACE_grid=zeros(180,360,length(tGRACE_comp))*nan;
GRACE_grid(:,:,indGRACE)=GRACE_data.graceGrid_CSR(:,:,iGRACE);
Amp_fft=Amp_fft.*mask;
Amp_fft_noband=Amp_fft_noband.*mask;
Amp_0=Amp_0.*mask;
Acf_dtr48=Acf_dtr48.*mask;
Pcf2_dtr48=Pcf2_dtr48.*mask;
Pcf3_dtr48=Pcf3_dtr48.*mask;
Acf_dtr72=Acf_dtr72.*mask;
Pcf2_dtr72=Pcf2_dtr72.*mask;
Pcf3_dtr72=Pcf3_dtr72.*mask;

save E:\work\DataAnaly\budykoData_global_v2 E_JBF E_GLDAS P_GLDAS P_TRMM Ep_GLDAS Ep_CGIAR...
    Amp_fft Amp_fft_noband Amp_0 mask t tGRACE_comp...
    Acf_dtr48 Pcf2_dtr48 Pcf3_dtr48 Acf_dtr72 Pcf2_dtr72 Pcf3_dtr72...
    E_JBF_grid E_GLDAS_grid P_GLDAS_grid Ep_GLDAS_grid GRACE_grid P_TRMM_grid ;
% save budykoData_global_GRDC E_JBF E_GLDAS P_GLDAS Ep_GLDAS Amp_fft Amp_fft_noband Amp_0 mask t...
%     Acf_dtr48 Pcf2_dtr48 Pcf3_dtr48 Acf_dtr72 Pcf2_dtr72 Pcf3_dtr72 Q_GRDC


%regress based on Amp_fft
% E=reshape(E_CLM,180*360,1);
% Ep=reshape(Ep_CLM,180*360,1);
% P=reshape(P_CLM,180*360,1);
% Amp=reshape(Amp_fft,180*360,1);
%[Enew,Ebudyko,R2] = budykoReg_Amp( E,Ep,P,Amp,1 );





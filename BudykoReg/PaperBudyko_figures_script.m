% figures plot script for Budyko paper
global ssType doMeanDepRm doAridityRm doPlot

%% figure 1 - global map
% GlobalMap_amp_p GlobalMap_amp1 GlobalMap_simind

% daterange=[200210,201409];
% [ GlobalGrid ] = GlobalGridOrg( daterange );
load('Y:\DataAnaly\GlobalGrid.mat')
yb=-61;
x=GlobalGrid.Amp_fft.lon;
y=GlobalGrid.Amp_fft.lat;
yind=find(y>=yb);
y=y(yind);

% amp/p
Amp_p=mean(GlobalGrid.Amp_fft.grid,3)./mean(GlobalGrid.Prcp_GLDAS.grid,3);
Amp_p=Amp_p(yind,:);
range=[0,0.3];
titlestr='Annual Amplitude over Precipitation A/P';
fname='E:\Kuai\DataAnaly\paper\GlobalMap_amp_p';
[f,range]=showGlobalMap( Amp_p,x,y,1,fname,titlestr,range,['yr']);

% amp1
Amp1=GlobalGrid.Amp1.grid;
Amp1=Amp1(yind,:);
range=[0,2];
titlestr='inter-annual variability index \gamma';
fname='E:\Kuai\DataAnaly\paper\GlobalMap_amp1';
[f,range]=showGlobalMap( Amp1,x,y,1,fname,titlestr,range,'[-]');

% Simind
Simind=GlobalGrid.SimIndex.grid;
Simind=Simind(yind,:);
range=[-1,1];
titlestr='Seasonality Index \xi';
fname='E:\Kuai\DataAnaly\paper\GlobalMap_simind';
[f,range]=showGlobalMap( Simind,x,y,1,fname,titlestr,range,'[-]');
fname='GlobalMap_simind_fullrange';
[f,range]=showGlobalMap( Simind,x,y,1,fname,titlestr);

% showGrid_3d( Simind ,x,y,GlobalGrid.Prcp_GLDAS.grid,GlobalGrid.t)
% ix=find(GlobalGrid.SimIndex.lon==-121.5);
% iy=find(GlobalGrid.SimIndex.lat==36.5);
% P=GlobalGrid.Prcp_GLDAS.grid(iy,ix,:);P=reshape(P,[length(GlobalGrid.t),1]);
% T=GlobalGrid.Tair_GLDAS.grid(iy,ix,:);T=reshape(T,[length(GlobalGrid.t),1]);
% [rsp,rst,SI]=SimIndex(P,T,12,1)
% 
% ts.v=reshape(GRACE.grid(j,i,:),[1,length(out.t)]);


%% test on some global maps
hist(reshape(temp,[length(x)*length(y),1]),[0:0.1:1,2:5,10:10:50])
shapeWorld=shaperead('Y:\Maps\WorldContinents.shp');
x=GlobalGrid.Amp_fft.lon;
y=GlobalGrid.Amp_fft.lat;

Ep=mean(GlobalGrid.rET_GLDAS.grid,3);
P=mean(GlobalGrid.Prcp_GLDAS.grid,3);
P(P==0)=nan;
temp=Ep./P;
temp(temp<10)=nan;
showGlobalMap( temp,x,y,1,[],[],[]);hold on
for i=1:length(shapeWorld)
    plot(shapeWorld(i).X,shapeWorld(i).Y,'k')
end

%% figure2
% HUC4Reg_Budyko HUC4Reg_BudykoCorrected HUC4Reg_regline
load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
Mississippi_exclude
doMeanDepRm=0;
doAridityRm=0;
doplot=1;
global doplotsave
doplotsave=1;
close all
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( HUCstr,HUCstr_t, {'AoP'}); % HUC4 regression
%[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS( HUCstr,HUCstr_t); % HUC4 regression
doplotsave=0;


suffix = '.eps';
fname='HUC4Reg_regline';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 7 
%comp_Ec_JBF

load('Y:\DataAnaly\BasinStr\GRDCstr_new.mat')
%load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
Fields = {'AoP','SimInd','Amp1','SoP','NDVI','acf_dtr48'};
ff=Fields([1 3 6]);
%global ssType doMeanDepRm doAridityRm doPlot
doPlot=1;
doMeanDepRm=0;
doAridityRm=0;
GRDCstr_t2=GRDCstr_t(1:48);
% Mississippi_exclude;
% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]= budykoReg_MS_SCP(HUCstr,HUCstr_t,ff,GRDCstr_t2);
% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]= budykoReg_MS_SCP(GRDCstr,GRDCstr_t,ff,GRDCstr_t2,b,bXe); % HUC4 par for GRDC
% 

[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]= budykoReg_MS_SCP(GRDCstr,GRDCstr_t,ff,GRDCstr_t2); % HUC4 par for GRDC

suffix = '.eps';
fname='comp_Ec_JBF';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 6 and 7 - comparison of JBF, Enew and GLDAS

Fields = {'AoP','SimInd','Amp1','SoP','NDVI','acf_dtr48'};
load('Y:\DataAnaly\GlobalGrid')
load('Y:\DataAnaly\BasinStr\GRDCstr_new.mat')
load('Y:\GRACE\GRACE_ERR_grid.mat')

global doErrRm docpAoP0 docpErrMean doErrRm_order doErrRm_minbound
global ssType doMeanDepRm doAridityRm doPlot

GRDCstr_t2=GRDCstr_t(1:48);
[C,ind,ind2]=intersect(GlobalGrid.t,GRDCstr_t2);

[ny,nx,nz]=size(GlobalGrid.Rainf_GLDAS.grid);
P=reshape(mean(GlobalGrid.Prcp_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
Ep=reshape(mean(GlobalGrid.rET_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
E=reshape(mean(GlobalGrid.Evap_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
Snow=reshape(mean(GlobalGrid.Snowf_GLDAS.grid(:,:,ind),3),[ny*nx,1]);
DAT=zeros(ny*nx,6)*nan;
DAT(:,1)=reshape(GlobalGrid.Amp_fft.grid,[ny*nx,1])./P;
DAT(:,2)=reshape(GlobalGrid.SimIndex.grid,[ny*nx,1]);
DAT(:,3)=reshape(GlobalGrid.Amp1.grid,[ny*nx,1]);
DAT(:,4)=Snow./P;
DAT(:,5)=reshape(GlobalGrid.NDVI.grid,[ny*nx,1]);
DAT(:,6)=reshape(GlobalGrid.acf_dtr48.grid,[ny*nx,1]);

GRACEerr(:,1)=reshape(leakage_Err,[ny*nx,1])*10;
GRACEerr(:,2)=reshape(measure_Err,[ny*nx,1])*10;
GRACEerr(GRACEerr==327670)=nan;


% interpolate AoP with a GRACEerr threshold
th=2;
[xx,yy]=meshgrid(GlobalGrid.GRACE.lon,GlobalGrid.GRACE.lat);
x1d=reshape(xx,[ny*nx,1]);
y1d=reshape(yy,[ny*nx,1]);
AoP1d=reshape(GlobalGrid.Amp_fft.grid,[ny*nx,1])./P;
AoP=reshape(AoP1d,[ny,nx]);

err=sqrt(sum(GRACEerr.^2,2));
err1d=err./nanmean(err);
errGrid=reshape(err1d,[ny,nx]);

bNan=isnan(AoP1d)|isinf(AoP1d);
bTh=err1d>th;
xq=x1d;xq(bNan)=[];
yq=y1d;yq(bNan)=[];
x=x1d;x(bNan|bTh)=[];
y=y1d;y(bNan|bTh)=[];
v=AoP1d;v(bNan|bTh)=[];

vq=griddata(x,y,v,xq,yq,'natural');
AoP1d_intp=AoP1d;
AoP1d_intp(~bNan)=vq;
AoP_intp=reshape(AoP1d_intp,[ny,nx]);
DAT(:,1)=AoP1d_intp;

%map for area that interpolated
close all
for thtest=[0.8,1,1.5,2]    
    map=ones(ny,nx);
    map(bNan)=0;
    bTh=err1d>thtest;
    map(bTh)=2;
    figure;imagesc(map);title(['intp=',num2str(thtest)]);
end

%scatter(EJBF1d,Enew,[],GRACEerr(:,2));
fixColorAxis([],[0,150],11,{'GRACE error(mm)'})
hold on
title('Comparison Between E^C vs E^{PJ}')
xlabel('E^{PJ} (mm/year)')
ylabel('E^C (mm/year)')
xlim([-100,1800])
ylim([-100,1800])
plot121Line;hold off
suffix = '.eps';
fname='compGrid_Ec_JBF';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

% add a constrain
%E(Ep./P>10)=nan;
%E(DAT(:,1)>0.4)=nan;

EJBF=mean(GlobalGrid.E_JBF.grid(:,:,1:48),3);
EGLDAS=mean(GlobalGrid.Evap_GLDAS.grid(:,:,1:48),3);
EJBF1d=reshape(EJBF,[ny*nx,1]);
EGLDAS1d=reshape(EGLDAS,[ny*nx,1]);

findex=[1 3 6];
ff=Fields(findex);
doErrRm=0;
docpAoP0=0;
docpErrMean=0;
doErrRm_order=0.5;
doErrRm_minbound=3;
doPlot=0;
doMeanDepRm=0;
doAridityRm=0;

%GRDC reg
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP(GRDCstr,GRDCstr_t,ff,GRDCstr_t2); 
%Global Grid reg
[Enew,Ebudyko,R2,b,D,bArid,dymean,ind,table]=...
    budykoReg_SCP( E,Ep,P,DAT(:,findex),b,[2,0],doPlot,GRACEerr);

Enewgrid=reshape(Enew,[ny,nx]);
rmse1=sqrt(nanmean((Enew-EJBF1d).^2));
rmse2=sqrt(nanmean((Enew-EGLDAS1d).^2));
rmse3=sqrt(nanmean((EJBF1d-EGLDAS1d).^2));

%1d plot
figure('Position', [100, 100, 1000, 800]);
scatter(EJBF1d,Enew,[],sqrt(sum(GRACEerr.^2,2)),'LineWidth',1.5);
%scatter(EJBF1d,Enew,[],GRACEerr(:,2));
fixColorAxis([],[0,150],11,{'GRACE error(mm)'})
hold on
title('Comparison Between E^C vs E^{PJ}')
xlabel('E^{PJ} (mm/year)')
ylabel('E^C (mm/year)')
xlim([-100,1800])
ylim([-100,1800])
plot121Line;hold off
suffix = '.eps';
fname='compGrid_Ec_JBF';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

a=measure_Err;a(a<1000)=0;a(a>1000)=2;
[dat,poly,in] = extractFromPolygon;
a(in)=1;
figure;imagesc(a)

figure
plot(Enew,EJBF1d,'bo');hold on
plot(Enew,EGLDAS1d,'r*');hold on
%plot(Enew,Ebudyko,'k.');hold on
plot121Line;hold off


% test map
x=GlobalGrid.Amp_fft.lon;
y=GlobalGrid.Amp_fft.lat;
[f,range]=showGlobalMap( Enewgrid-EGLDAS,x,y,1,[],[],[-600,600]);

[f,range]=showGlobalMap( leakage_Err,x,y,1,[]);
[f,range]=showGlobalMap( measure_Err,x,y,1,[]);



%plot global map
yb=-61;
x=GlobalGrid.Amp_fft.lon;
y=GlobalGrid.Amp_fft.lat;
yind=find(y>=yb);
y=y(yind);

% interp area
map=ones(ny,nx);
map(bNan)=nan;
bTh=err1d>th;
map(bTh)=2;
map2=map(yind,:);
titlestr='Interpolated Region';
fname='IntpArea';
[f,range]=showGlobalMap( map2,x,y,1,[],titlestr);
colorbar off
suffix = '.eps';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

Enewgrid=Enewgrid(yind,:);
titlestr='E^C(2002/10 - 2006/09)';
fname='GlobalProduct_Enew';
range=[0,1500];
[f,range]=showGlobalMap( Enewgrid,x,y,1,fname,titlestr,range);

EJBFgrid=EJBF(yind,:);
titlestr='PT-JPL Evaporation (2002/10 - 2006/09)';
fname='GlobalProduct_Ejbf';
range=[0,1500];
[f,range]=showGlobalMap( EJBFgrid,x,y,1,fname,titlestr,range);

EGLDASgrid=EGLDAS(yind,:);
titlestr='GLDAS Evaporation (2002/10 - 2006/09)';
fname='GlobalProduct_Egldas';
range=[0,1500];
[f,range]=showGlobalMap( EGLDASgrid,x,y,1,fname,titlestr,range);


Ediff1=Enewgrid-EJBFgrid;
titlestr='E^C - E^{PJ} (2002/10 - 2006/09)';
fname='GlobalProduct_diff_Ec_Ejbf';
range=[-500,500];
[f,range]=showGlobalMap( Ediff1,x,y,1,fname,titlestr,range);

Ediff2=Enewgrid-EGLDASgrid;
titlestr='E^C - E^{GLDAS}  (2002/10 - 2006/09)';
fname='GlobalProduct_diff_Ec_Egldas';
range=[-500,500];
[f,range]=showGlobalMap( Ediff2,x,y,1,fname,titlestr,range);

Ediff3=EJBFgrid-EGLDASgrid;
titlestr='E^{PJ} - E^{GLDAS}  (2002/10 - 2006/09)';
fname='GlobalProduct_diff_Ejbf_Egldas';
range=[-700,700];
[f,range]=showGlobalMap( Ediff3,x,y,1,fname,titlestr,range);

%% GRACE leakage errorgrace
GRACEerr=load('Y:\GRACE\GRACE_ERR_grid.mat');
leakage_Err=GRACEerr.leakage_Err;
measure_Err=GRACEerr.measure_Err;

leakage_Err(leakage_Err==32767)=nan;
leakage_Err=leakage_Err*10;
measure_Err(measure_Err==32767)=nan;
measure_Err=measure_Err*10;

%plot
yb=-61;
x=GRACEerr.lon;
y=GRACEerr.lat;
yind=find(y>=yb);
y=y(yind);
leakage_Err=leakage_Err(yind,:);
measure_Err=measure_Err(yind,:);

fname='GRACE_leakageErr';
titlestr='GRACE Leakage Error';
[f,range]=showGlobalMap( leakage_Err,x,y,1,fname,titlestr,[0,200],'mm');

fname='GRACE_measureErr';
titlestr='GRACE Measurement Error';
[f,range]=showGlobalMap( measure_Err,x,y,1,fname,titlestr,[-20,80],'mm');

% plot 121 plot between leakage error and e difference
leakageErr1d=reshape(leakage_Err,[151*360,1]);
measureErr1d=reshape(measure_Err,[151*360,1]);

Ediff1d=reshape(Ediff1,[151*360,1]);
plot(leakageErr1d,abs(Ediff1d),'*')
xlim([0,200])
ylim([0,750])

plot(measureErr1d,abs(Ediff1d),'*')


%% sp
load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
outputshpfile='Y:\HUCs\HUC4_main_data.shp';
HUCshpfile='Y:\DataAnaly\HUC\HUC4_main.shp';
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( HUCstr,HUCstr_t, {'AoP'}); % HUC4 regression
for i=1:length(HUCstr)
    if ismember(i,ind)
        HUCstr(i).sel=1;
    else
        HUCstr(i).sel=0;
    end
end
HUCstr2shp( HUCstr,HUCstr_t, HUCshpfile, outputshpfile )

%% test of new idea about leakage error and measurement error
load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
load('Y:\DataAnaly\BasinStr\GRDCstr_new.mat')

Fields = {'AoP','SimInd','Amp1','SoP','NDVI','acf_dtr48'};
ff=Fields([1,3,6]);
ff=Fields([1]);


Mississippi_exclude

global doErrRm doPlot docpAoP0 
% doErrRm index of AoP term
% donotRecalAoP0 0: recal aop0; !0: v of AoP0
doErrRm=1;
doPlot=0;
docpAoP0=0;

[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( HUCstr,HUCstr_t,ff); R2

docpAoP0=0;
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff); R2

% transfer from HUC4 to GRDC
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( HUCstr,HUCstr_t,ff,GRDCstr_t); R2
docpAoP0=0;
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff,HUCstr_t,b); R2

% transfer from GRDC to HUC4
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( GRDCstr,GRDCstr_t,ff,HUCstr_t); R2
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]=...
    budykoReg_MS_SCP( HUCstr,HUCstr_t,ff,GRDCstr_t,b); R2














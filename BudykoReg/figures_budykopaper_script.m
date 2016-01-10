% figures plot script for Budyko paper
global ssType doMeanDepRm doAridityRm doPlot

%% figure 1
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
range=[0,0.5];
titlestr='Annual Amplitude / Precipitation (2002/10 - 2010/09)';
fname='GlobalMap_amp_p';
[f,range]=showGlobalMap( Amp_p,x,y,1,fname,titlestr,range);

% amp1
Amp1=GlobalGrid.Amp1.grid;
Amp1=Amp1(yind,:);
range=[0,2];
titlestr='inter-annual variability index \gamma (2002/10 - 2010/09)';
fname='GlobalMap_amp1';
[f,range]=showGlobalMap( Amp1,x,y,1,fname,titlestr,range);

% Simind
Simind=GlobalGrid.SimIndex.grid;
Simind=Simind(yind,:);
range=[-1,1];
titlestr='Seasonality Index \xi (2002/10 - 2010/09)';
fname='GlobalMap_simind';
[f,range]=showGlobalMap( Simind,x,y,1,fname,titlestr,range);
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
load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
Mississippi_exclude
doMeanDepRm=0;
doAridityRm=0;
doplot=1;
close all
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( HUCstr,HUCstr_t, {'AoP'}); % HUC4 regression
%[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS( HUCstr,HUCstr_t); % HUC4 regression

suffix = '.eps';
fname='HUC4Reg_regline';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 5
load('Y:\DataAnaly\BasinStr\GRDCstr_new.mat')
%load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
Fields = {'AoP','SimInd','Amp1','SoP','NDVI','acf_dtr48'};
ff=Fields([1 3 6]);
%global ssType doMeanDepRm doAridityRm doPlot
doPlot=1;
doMeanDepRm=1;
doAridityRm=1;
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

%% figure 6
load('Y:\DataAnaly\GlobalGrid')
load('Y:\DataAnaly\BasinStr\GRDCstr_new.mat')

Fields = {'AoP','SimInd','Amp1','SoP','NDVI','acf_dtr48'};
findex=[1 3 6];
ff=Fields(findex);
%global ssType doMeanDepRm doAridityRm doPlot
doPlot=1;
doMeanDepRm=0;
doAridityRm=0;
GRDCstr_t2=GRDCstr_t(1:48);
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe,stats,table]= budykoReg_MS_SCP(GRDCstr,GRDCstr_t,ff,GRDCstr_t2); % HUC4 par for GRDC
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
[Enew,Ebudyko,R2,b,D,bArid,dymean,ind,table]=budykoReg_SCP( E,Ep,P,DAT(:,findex),b,[2,0],doPlot);

Enewgrid=reshape(Enew,[ny,nx]);
EJBF=mean(GlobalGrid.E_JBF.grid(:,:,1:48),3);

%plot
yb=-61;
x=GlobalGrid.Amp_fft.lon;
y=GlobalGrid.Amp_fft.lat;
yind=find(y>=yb);
y=y(yind);

Enewgrid=Enewgrid(yind,:);
titlestr='Corrected Evaporation (2002/10 - 2006/09)';
fname='GlobalProduct_Enew';
range=[0,1500];
[f,range]=showGlobalMap( Enewgrid,x,y,1,fname,titlestr,range);

EJBFgrid=EJBF(yind,:);
titlestr='JBF Evaporation (2002/10 - 2006/09)';
fname='GlobalProduct_Ejbf';
range=[0,1500];
[f,range]=showGlobalMap( EJBFgrid,x,y,1,fname,titlestr,range);

Ediff=Enewgrid-EJBFgrid;
titlestr='E_c - E_JBF (2002/10 - 2006/09)';
fname='GlobalProduct_diff';
range=[-800,800];
[f,range]=showGlobalMap( Ediff,x,y,1,fname,titlestr,range);


















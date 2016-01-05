% figures plot script for Budyko paper

%% figure 1
% daterange=[200301,201212];
% [ GlobalGrid ] = GlobalGridOrg( daterange );
load('Y:\DataAnaly\GlobalGrid')

Amp_p=mean(GlobalGrid.Amp_fft.grid,3)./mean(GlobalGrid.Prcp_GLDAS.grid,3);
x=GlobalGrid.Amp_fft.lon;
y=GlobalGrid.Amp_fft.lat;
range=[0,0.5]
[f,range]=showGlobalMap( Amp_p,x,y,'Annual Amplitude / Precipitation',range);
saveas(f,'Y:\DataAnaly\paper\f1_amp_p.fig')

Simind=GlobalGrid.SimIndex.grid;
[f,range]=showGlobalMap( Simind,x,y,'Seasonality Index \xi');
saveas(f,'Y:\DataAnaly\paper\f1_simind.fig')

Amp1=GlobalGrid.Amp1.grid;
[f,range]=showGlobalMap( Amp1,x,y,'\gamma',[0,3]);
saveas(f,'Y:\DataAnaly\paper\f1_amp1.fig')

%% figure2
load('Y:\DataAnaly\HUCstr_new.mat')
Mississippi_exclude
doMeanDepRm=1;
doAridityRm=1;
doplot=1;
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( HUCstr,HUCstr_t, {'AoP'}); % HUC4 regression
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS( HUCstr,HUCstr_t); % HUC4 regression

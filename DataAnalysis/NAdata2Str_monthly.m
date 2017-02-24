function [BasinStr,BasinStr_t]=NAdata2Str_monthly( maskNLDAS,maskGRACE,maskNDVI,BasinStr, BasinStr_t)
%Merge all useful NLDAS and GRACE data to Str. Input shapefile. 

% default set up of all data directory
crdNLDASfile='Y:\DataAnaly\crd\crd_NLDAS_NA.mat';
crdGRACEfile='Y:\DataAnaly\crd\crd_GRACE_global.mat';
NLDAS_NOAH_folder='Y:\NLDAS\matfile\monthly\NOAH';
NLDAS_FORA_folder='Y:\NLDAS\matfile\monthly\FORA';
NLDAS_rET_file='Y:\DataAnaly\rET\rET_NLDAS_monthly.mat';
GRACE_file='Y:\GRACE\gracegrid_CSR.mat';
GRACEerr_file='Y:\GRACE\GRACE_ERR_grid.mat';

NDVI_file='Y:\DataAnaly\GIMMS\NDVI_avg_NA.mat'; % Using NA data here result from memory issue

%% NLDAS
% Rainfall
fieldstr='ARAIN';
matfile= [NLDAS_NOAH_folder,'\',fieldstr,'.mat'];
[BasinStr,BasinStr_t]=NLDAS2HUC( matfile, fieldstr,'Rain', maskNLDAS, BasinStr, BasinStr_t );

% Snowfall
fieldstr='ASNOW';
matfile= [NLDAS_NOAH_folder,'\',fieldstr,'.mat'];
[BasinStr,BasinStr_t]=NLDAS2HUC( matfile, fieldstr,'Snow', maskNLDAS, BasinStr, BasinStr_t );

% T
fieldstr='TMP';
matfile= [NLDAS_FORA_folder,'\',fieldstr,'.mat'];
[BasinStr,BasinStr_t]=NLDAS2HUC( matfile, fieldstr,'Tmp', maskNLDAS, BasinStr, BasinStr_t );

% rET 
crdNLDAS=load(crdNLDASfile);
rETdata=load(NLDAS_rET_file);
BasinStr = grid2HUC_month('rET3',rETdata.rET3,rETdata.t,maskNLDAS,BasinStr,BasinStr_t);

%% GRACE
% GRACE data
crdGRACE=load(crdGRACEfile);
GRACEdata=load(GRACE_file);
BasinStr = grid2HUC_month('S',GRACEdata.graceGrid*10,GRACEdata.t,maskGRACE,BasinStr,BasinStr_t);

% GRACE Err
GRACEerrdata=load(GRACEerr_file);
BasinStr = grid2HUC_month('GRACE_leakageErr',GRACEerrdata.leakage_Err*10,1,maskGRACE,BasinStr,1);
BasinStr = grid2HUC_month('GRACE_measureErr',GRACEerrdata.measure_Err*10,1,maskGRACE,BasinStr,1);

% GRACE data of all time
t=GRACEdata.t;
tmall=unique(datenumMulti(t(1):t(end),3));
tmalln=datenumMulti(tmall,1);
BasinStr = grid2HUC_month('GRACE',GRACEdata.graceGrid*10,GRACEdata.t,maskGRACE,BasinStr,tmalln);
for i=1:length(BasinStr)
    BasinStr(i).GRACEt=tmalln;
end

% Amplitude
sd=20021001;
ed=20140930;
BasinStr=amp2HUC(BasinStr,sd,ed,0,1001);
BasinStr=amp2HUC(BasinStr,sd,ed,1,1001);
BasinStr=amp2HUC_fft(BasinStr,sd,ed);

% Acf and Pcf
BasinStr  = acf2HUC_detrend( BasinStr,sd,ed);

%% GIMMS NDVI
load(NDVI_file)
NDVIdata=load(NDVI_file);
BasinStr = grid2HUC_month('NDVI',NDVIdata.NDVI,1,maskNDVI,BasinStr,1);


%% Seasonal Similarity Index
for i=1:length(BasinStr)
    P=BasinStr(i).Rain+BasinStr(i).Snow;
    T=BasinStr(i).Tmp;
    [ SimInd ] = SimIndex_cal( P, T, 12);
    BasinStr(i).SimInd=SimInd;
end


%%

%save outmatfile BasinStr BasinStr_t
end


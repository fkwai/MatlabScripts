function [BasinStr,BasinStr_t]=Global2Datastr_monthly(maskGLDAS,maskGRACE,maskNDVI,BasinStr,BasinStr_t)
%%Merge all useful GLDAS, TRMM, JBF and GRACE data to Str. Input mask. 
% load('Y:\DataAnaly\mask\mask_GRDC.mat')
% load('Y:\DataAnaly\HUCstr_new2.mat')
% shapefile='Y:\GRDC_UNH\GIS_dataset\grdc_basins_smoothed_sel.shp';
% BasinStr = initialHUCstr( shapefile,'GRDC_NO' );
% BasinStr_t=HUCstr_t;
% outmatfile='Y:\DataAnaly\GRDCstr_new.mat'

%% default set up of all data dir
E_JBF_dir='Y:\ET_JBF\AET_JBF_10deg';
GRACE_dir='Y:\GRACE\graceGrid_CSR.mat';
GLDAS_dir='Y:\GLDAS\Monthly\GLDAS_matfile\NOAH_V2';
NDVI_dir='Y:\DataAnaly\GIMMS\NDVI_avg.mat';
GLDAS_rET_dir='Y:\DataAnaly\rET\rET_GLDAS_monthly.mat';
TRMMdir='Y:\TRMM\TRMM_res.mat';

t=BasinStr_t;
tym=datenumMulti(t,3);

maskJBF=maskGRACE;
maskTRMM=maskGRACE;
maskRET=maskGRACE;

%% GRACE
% GRACE data
disp('GRACE');tic
GRACEdata=load(GRACE_dir);
BasinStr = grid2HUC_month('S',GRACEdata.graceGrid*10,GRACEdata.t,maskGRACE,BasinStr,BasinStr_t);

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
ed=20141001;
BasinStr=amp2HUC( BasinStr,sd,ed,0,1001 );
BasinStr=amp2HUC( BasinStr,sd,ed,1,1001 );
BasinStr=amp2HUC_fft( BasinStr,sd,ed);

% Acf and Pcf
BasinStr  = acf2HUC_detrend( BasinStr,sd,ed);
toc

%% GLDAS
disp('GLDAS');tic
% Rainfall
fieldstr='Rainf';
matfile= [GLDAS_dir,'\',fieldstr,'.mat'];
[BasinStr,BasinStr_t]=NLDAS2HUC( matfile, fieldstr,'Rain', maskGLDAS, BasinStr, BasinStr_t );

% Snowfall
fieldstr='Snowf';
matfile= [GLDAS_dir,'\',fieldstr,'.mat'];
[BasinStr,BasinStr_t]=NLDAS2HUC( matfile, fieldstr,'Snow', maskGLDAS, BasinStr, BasinStr_t );

% T
fieldstr='Tair';
matfile= [GLDAS_dir,'\',fieldstr,'.mat'];
[BasinStr,BasinStr_t]=NLDAS2HUC( matfile, fieldstr,'Tmp', maskGLDAS, BasinStr, BasinStr_t );

% rET 
rETdata=load(GLDAS_rET_dir);
BasinStr = grid2HUC_month('rET3',rETdata.rET3,rETdata.t,maskRET,BasinStr,BasinStr_t);

% change unit to mm/month
Y=floor(tym/100);M=tym-Y*100;
nday=eomday(Y,M);
for i=1:length(BasinStr)
    BasinStr(i).Rain=BasinStr(i).Rain*60*60*24.*nday;
    BasinStr(i).Snow=BasinStr(i).Snow*60*60*24.*nday;
    BasinStr(i).P_GLDAS=BasinStr(i).Rain+BasinStr(i).Snow;
end
toc

%% E JBF
disp('E_JBF');tic
E_JBF_data=load(E_JBF_dir);
E_JBF_data.E_JBF(E_JBF_data.E_JBF==-99)=nan;

% Temp
Tair_GLDAS_data=load([GLDAS_dir,'\Tair.mat']);
[Tair_grid,xx,yy] = data2grid3d( Tair_GLDAS_data.Tair,Tair_GLDAS_data.crd(:,1),Tair_GLDAS_data.crd(:,2),1);
yy=[89.5:-1:-89.5]';
Tair=zeros(length(yy),length(xx),length(E_JBF_data.tym))*nan;
[C,ind1,ind2]=intersect(E_JBF_data.tym,Tair_GLDAS_data.t);
Tair(1:150,:,ind1)=Tair_grid(:,:,ind2);
% change unit
Y=floor(E_JBF_data.tym/100);M=E_JBF_data.tym-Y*100;
ndayZ_JBF=reshape(eomday(Y,M),1,1,length(E_JBF_data.tym));
ndayG_JBF=repmat(ndayZ_JBF,size(E_JBF_data.E_JBF,1),size(E_JBF_data.E_JBF,2));
E_JBF=wm2mmPerMonth(E_JBF_data.E_JBF,Tair,ndayG_JBF)*12;

BasinStr = grid2HUC_month('E_JBF',E_JBF,E_JBF_data.tym,maskJBF,BasinStr,BasinStr_t);
toc

%% P TRMM
disp('P_TRMM');tic
TRMM_data=load(TRMMdir);
TRMM_grid_temp(41:140,:,:)=TRMM_data.TRMM_res;
TRMM_grid_temp(141:180,:,:)=nan;
TRMM_grid_temp(1:40,:)=nan;
TRMM_grid=[TRMM_grid_temp(:,181:360,:),TRMM_grid_temp(:,1:180,:)];
BasinStr = grid2HUC_month('P_TRMM',TRMM_grid,TRMM_data.t,maskTRMM,BasinStr,BasinStr_t);
toc

%% GIMMS NDVI
disp('NDVI');tic
NDVIdata=load(NDVI_dir);
BasinStr = grid2HUC_month('NDVI',NDVIdata.NDVI,1,maskNDVI,BasinStr,1);
toc

%% Seasonal Similarity Index
disp('SimIndex');tic
for i=1:length(BasinStr)
    P=BasinStr(i).Rain+BasinStr(i).Snow;
    T=BasinStr(i).Tmp;
    SimInd = SimIndex_cal( P, T, 12);
    BasinStr(i).SimInd=SimInd;
end
toc

%save Y:\DataAnaly\GRDCstr_new.mat GRDCstr GRDCstr_t
end


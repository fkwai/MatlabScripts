tic
SMAP=load('Y:\SMAP\SMP_L2_q.mat');
toc
tic
GLDAS=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_SoilM.mat');
toc


load('Y:\GLDAS\maskGLDAS_025.mat')

tic
dataSMAP_q=zeros(length(GLDAS.lat),length(GLDAS.lon),length(GLDAS.tnum))*nan;
tnumSMAP_q=zeros(length(SMAP.tnum));
for j=1:length(SMAP.tnum)
    j
    gridtemp=SMAP.data(:,:,j);
    [temp2,iGLDAS]=min(abs(SMAP.tnum(j)-GLDAS.tnum));
    C=cat(3,gridtemp,dataSMAP_q(:,:,iGLDAS));
    dataSMAP_q(:,:,iGLDAS)=nanmean(C,3);
end
grid2csv_time( dataSMAP_q,GLDAS.lat,GLDAS.lon,GLDAS.tnum,mask,'D:\Kuai\rnnSMAP\tDB_SMPq\' )
toc

%% read all GLDAS data

filename='Y:\GLDAS\data\GLDAS_V1\GLDAS_NOAH025SUBP_3H\2016\001\GLDAS_NOAH025SUBP_3H.A2016001.0000.001.2016041013331.grb';
ParamTable='Y:\GLDAS\gribtab_GLDAS_NOAH.txt';
gldas=read_grib(filename,ParamTable,-1,'ScreenDiag',0);
fieldLst={gldas.parameter}';
fieldLst{14}='SoilTemp';
indLst=[1:7,9:14,21:28];

for i=2:length(indLst)
    i
    tic
    ind=indLst(i);
    field=fieldLst{ind};
    sd=20150331;
    ed=20160831;
    sdn=datenumMulti(sd,1);
    edn=datenumMulti(ed,1);
    dataGLDAS=zeros(600,1440,8*length(sdn:edn))*nan;
    tnumGLDAS=[];
    lat0=[];
    lon0=[];
    k=1;
    for t=sdn:edn        
        disp(datestr(t))
        [data,lat,lon,tnum] = readGLDAS_NOAH(t,ind);
        dataGLDAS(:,:,k:k+7)=data;
        k=k+8;
        tnumGLDAS=cat(1,tnumGLDAS,tnum);
    end    
    data=dataGLDAS(:,:,1:end);
    tnum=tnumGLDAS;
    matfile=['Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_',field,'.mat'];
    save(matfile,'data','lat','lon','tnum','-v7.3')
    grid2csv_time( data,lat,lon,tnum,mask,['D:\Kuai\rnnSMAP\tDB_',field,'\'] )
    toc
end

%% update ub, lb for normalization
filename='Y:\GLDAS\data\GLDAS_V1\GLDAS_NOAH025SUBP_3H\2016\001\GLDAS_NOAH025SUBP_3H.A2016001.0000.001.2016041013331.grb';
ParamTable='Y:\GLDAS\gribtab_GLDAS_NOAH.txt';
gldas=read_grib(filename,ParamTable,-1,'ScreenDiag',0);
fieldLst={gldas.parameter}';
fieldLst{14}='SoilTemp';
indLst=[1:14,22:28];
perc=10;

for i=8:length(indLst)
    tic    
    ind=indLst(i);
    field=fieldLst{ind};
    matfile=['Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_',field,'.mat'];
    GLDAS=load(matfile);
    
    data=GLDAS.data(:);
    data(isnan(data))=[];
    lb=prctile(data,perc);
    ub=prctile(data,100-perc);
    
    data80=data(data>=lb &data<=ub);
    m=mean(data80);
    sigma=std(data80);
    
    stat=[lb;ub;m;sigma];
    statFile=['D:\Kuai\rnnSMAP\tDB_',field,'\stat.csv'];
    dlmwrite(statFile, stat,'precision',8);
    toc
end


tic
% field='soilM';
% matfile=['Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_',field,'.mat'];
field='SMPq';
matfile='Y:\SMAP\SMP_L2_q.mat';
GLDAS=load(matfile);

data=GLDAS.data(:);
data(isnan(data))=[];
lb=prctile(data,perc);
ub=prctile(data,100-perc);

data80=data(data>=lb &data<=ub);
m=mean(data80);
sigma=std(data80);

stat=[lb;ub;m;sigma];
statFile=['D:\Kuai\rnnSMAP\tDB_',field,'\stat.csv'];
dlmwrite(statFile, stat,'precision',8);
toc


%% NDVI & LULC
LULCFile='Y:\NLCD\nlcd_2011_landcover_2011_edition_2014_10_10\nlcd_2011_landcover_proj_resample.tif';
NDVIFile='Y:\GIMMS\avg.tif';
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat')
%load('Y:\GLDAS\maskGLDAS_025.mat')
load('Y:\GLDAS\maskCONUS.mat')
mask=maskCONUS;
% NDVI
[gridNDVI,refNDVI]=geotiffread(NDVIFile);
lonNDVI=refNDVI.LongitudeLimits(1)+refNDVI.CellExtentInLongitude/2:...
    refNDVI.CellExtentInLongitude:...
    refNDVI.LongitudeLimits(2)-refNDVI.CellExtentInLongitude/2;
latNDVI=[refNDVI.LatitudeLimits(2)-refNDVI.CellExtentInLatitude/2:...
    -refNDVI.CellExtentInLatitude:...
    refNDVI.LatitudeLimits(1)+refNDVI.CellExtentInLatitude/2]';
gridNDVI_int=interp2(lonNDVI,latNDVI,gridNDVI,lon,lat);
grid2csv_time_const(gridNDVI_int,lat,lon,mask,'E:\Kuai\rnnSMAP\Database\tDBconst_NDVI\')

% LULC (only CONUS)
[gridLULC,cmapLULC,refLULC]=geotiffread(LULCFile);
lonLULC=refLULC.LongitudeLimits(1)+refLULC.CellExtentInLongitude/2:...
    refLULC.CellExtentInLongitude:...
    refLULC.LongitudeLimits(2)-refLULC.CellExtentInLongitude/2;
latLULC=[refLULC.LatitudeLimits(2)-refLULC.CellExtentInLatitude/2:...
    -refLULC.CellExtentInLatitude:...
    refLULC.LatitudeLimits(1)+refLULC.CellExtentInLatitude/2]';
gridLULC=double(gridLULC);
%gridLULC(gridLULC==0)=nan;
gridLULC(gridLULC==255)=0;
% construct US grid
latBoundUS=[25,50];
lonBoundUS=[-125,-66.5];
latIndUS=find(lat>=latBoundUS(1)&lat<=latBoundUS(2));
lonIndUS=find(lon>=lonBoundUS(1)&lon<=lonBoundUS(2));
maskInd = mask2Ind_SMAP();
maskIndUS=maskInd(latIndUS,lonIndUS);
latUS=lat(latIndUS);
lonUS=lon(lonIndUS);
vq=interpGridArea(lonLULC,latLULC,gridLULC,lonUS,latUS,'mode');
gridLULC_int=zeros(size(mask));
gridLULC_int(latIndUS,lonIndUS)=vq;
grid2csv_time_const(gridLULC_int,lat,lon,mask,'E:\Kuai\rnnSMAP\Database\tDBconst_LULC\')

%% GLDAS soilM anormly
tic
GLDAS=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_SoilM.mat');
toc

% loop due to memory issue
%data=GLDAS.data-repmat(nanmean(GLDAS.data,3),[1,1,length(GLDAS.tnum)]);
tic
for j=1:length(GLDAS.lat)
    for i=1:length(GLDAS.lon)
        m=nanmean(GLDAS.data(j,i,:));
        GLDAS.data(j,i,:)=GLDAS.data(j,i,:)-m;        
    end
end
toc

load('Y:\GLDAS\maskGLDAS_025.mat')
grid2csv_time(GLDAS.data,GLDAS.lat,GLDAS.lon,GLDAS.tnum,mask,'D:\Kuai\rnnSMAP\tDB_soilM_Anormly\')

data=GLDAS.data(:);
data(isnan(data))=[];
perc=10;
lb=prctile(data,perc);
ub=prctile(data,100-perc);
data80=data(data>=lb &data<=ub);
m=mean(data80);
sigma=std(data80);
stat=[lb;ub;m;sigma];
statFile=['D:\Kuai\rnnSMAP\tDB_soilM_Anormly\stat.csv'];
dlmwrite(statFile, stat,'precision',8);

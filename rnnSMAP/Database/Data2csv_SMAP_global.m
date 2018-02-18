
% this script will write all data to csv of SMAP CONUS grid, Daily.

global kPath
% maskFile is created by dataset/datasetMask
maskFile=[kPath.SMAP,'maskSMAP_L3.mat'];
yrLst=2000:2016;
dirDB=[kPath.DBSMAP_L3_Global,'Global',filesep];

maskMat=load(maskFile);
crd=[maskMat.lat1D,maskMat.lon1D];

%% initial Database - each year from 0401 to 0401 next year
if ~isdir(dirDB)
    mkdir(dirDB)
end
initDBcsvGlobal(dirDB,yrLst,0401,crd)

%% GLDAS
% initial all fields
dirGLDAS=kPath.GLDAS_NOAH_Mat;
fileGLDAS=dir([kPath.GLDAS_NOAH_Mat,'2016',filesep,'*.mat']);
fieldLst=cell(length(fileGLDAS),1);
for k=1:length(fieldLst)
    fieldName=fileGLDAS(k).name(1:end-4);
    fieldLst{k}=fieldName;
end

yrLstG=[yrLst,yrLst(end)+1];
tnumG=[datenumMulti(yrLstG(1)*10000+101):datenumMulti(yrLstG(end)*10000+1231)]';
nt=length(tnumG);
for iField=1:length(fieldLst)
    % read GLDAS by field
    fieldName=fieldLst{iField};
    dataG=zeros(600,1440,nt);
    for iY=1:length(yrLstG)
        yrStr=num2str(yrLstG(iY));
        tic;
        matG=load([dirGLDAS,num2str(yrLstG(iY)),filesep,fieldName,'.mat']);
        [C,ind1,ind2]=intersect(matG.tnum,tnumG);
        dataG(:,:,ind2)=matG.(fieldName);
        disp(['readGLDAS ',fieldName, ' ',yrStr, ' ', num2str(toc)])
    end
    lonG=matG.lon;
    latG=matG.lat;
    lon=maskMat.lon;
    lat=maskMat.lat;
    mask=maskMat.mask;
    
    % intp to SMAP grid
    [varName,mF,aF]=fieldGLDAS(fieldName);    
    dataCell=cell(length(yrLst),1);
    for iY=1:length(yrLst)
        yr=yrLst(iY);
        yrStr=num2str(yr);        
        dirDByear=[dirDB,yrStr,filesep];
        tnum=csvread([dirDByear,'time.csv']);
        [C,ind1,ind2]=intersect(tnum,tnumG);
        dataCell{iY}=dataG(:,:,ind2);
    end
    
    % write to database
    parObj=parpool(18);
    parfor iY=1:length(yrLst)
 		yr=yrLst(iY);
        yrStr=num2str(yr);        
        dirDByear=[dirDB,yrStr,filesep];
        tnum=csvread([dirDByear,'time.csv']);
        tic;
        dataTemp=dataCell{iY};
        dataIntp=interpGridArea(lonG,latG,dataTemp,lon,lat);
        dataIntp=(dataIntp+aF).*mF;
        grid2csvDB(dataIntp,tnum,dirDByear,mask,varName)
        disp(['intp to SMAP ',varName, ' ',yrStr, ' ', num2str(toc)])
    end
    delete(parObj)
end

%% TRMM
latTRMM=[49.875:-0.25:-49.875]';
lonTRMM=-179.875:0.25:179.875;

% test code 
% dd=readTRMM(20160229);
% [f,cmap]=showMap(dd,latTRMM,lonTRMM,'colorRange',[0,100]);

dirTRMM=kPath.TRMM_daily;
lon=maskMat.lon;
lat=maskMat.lat;
mask=maskMat.mask;
parfor iY=1:length(yrLst)
    yr=yrLst(iY);
    yrStr=num2str(yr);        
    dirDByear=[dirDB,yrStr,filesep];
    tLst=csvread([dirDByear,'time.csv']);
    data=zeros(length(latTRMM),length(lonTRMM),length(tLst));
    disp(yrStr)
    tic
    for k=1:length(tLst)
        t=tLst(k);
        temp = readTRMM(t,'dirTRMM',dirTRMM);
        data(:,:,k)=temp;
    end
    dataIntp=interpGridArea(lonTRMM,latTRMM,data,lon,lat);
    grid2csvDB(dataIntp,tLst,dirDByear,mask,'TRMM');
    toc
end



%% SMAP
matFileLst={[kPath.SMAP,'SMAP_L3_AM.mat'],[kPath.SMAP,'SMAP_L3_PM.mat']};
varLst={'SMAP_AM','SMAP_PM'};
for iD=1:length(matFileLst)
    matSMAP=load(matFileLst{iD});
    yrLstSMAP=[2015,2016];
    for iY=1:length(yrLstSMAP)
        dirDByear=[dirDB,num2str(yrLstSMAP(iY)),filesep];
        grid2csvDB(matSMAP.data,matSMAP.tnum,dirDByear,mask,varLst{iD})
    end
end

%% SMAP flags
dirDBconst=[dirDB,'const',filesep];
flagMat=load([kPath.SMAP,'SMAP_L3_flag_AM.mat']);
%PM is same as AM except for vegDense
%matFlag2=load([kPath.SMAP,'SMAP_L3_flag_PM.mat']); 

% combine [coast, ice, mount, staWater,urban,vegDense]
indComb=[2,3,5,7,8];
dataTemp=flagMat.data(:,:,indComb);
dataTemp=round(dataTemp);
data=zeros(size(dataTemp,1),size(dataTemp,2));
for k=1:length(indComb)
    data(dataTemp(:,:,k)==1)=k;
end
data(sum(dataTemp,3)>1)=length(indComb)+1;
grid2csvDB(data,0,dirDBconst,maskMat.mask,'flag_extraOrd')

indSingle=1:size(flagMat.data,3);
indSingle(indComb)=[];
for k=1:length(indSingle)
    ind=indSingle(k);
    grid2csvDB(flagMat.data(:,:,ind),0,dirDBconst,maskMat.mask,flagMat.fieldLst{ind})
end

%% other constant
% Soil
soilMat=load('/mnt/sdb1/Database/SoilGlobal/wise5by5min_v1b/soilMap.mat');
dirDBconst=[dirDB,'const',filesep];
field={'Sand','Silt','Clay','Capa','Bulk'};
for k=1:length(field)
    k
    tic
    data=soilMat.(field{k})(:,:,1);
    dataIntp=interpGridArea(soilMat.lon,soilMat.lat,data,maskMat.lon,maskMat.lat,'mean');
    grid2csvDB(dataIntp,0,dirDBconst,maskMat.mask,field{k})
    toc
end

% NDVI
tic
NDVIFile='/mnt/sdb1/Database/GIMMS/avg.tif';
[gridNDVI,refNDVI]=geotiffread(NDVIFile);
lonNDVI=refNDVI.LongitudeLimits(1)+refNDVI.CellExtentInLongitude/2:...
    refNDVI.CellExtentInLongitude:...
    refNDVI.LongitudeLimits(2)-refNDVI.CellExtentInLongitude/2;
latNDVI=[refNDVI.LatitudeLimits(2)-refNDVI.CellExtentInLatitude/2:...
    -refNDVI.CellExtentInLatitude:...
    refNDVI.LatitudeLimits(1)+refNDVI.CellExtentInLatitude/2]';
dataIntp=interpGridArea(lonNDVI,latNDVI,gridNDVI,maskMat.lon,maskMat.lat,'mean');
grid2csvDB(dataIntp,0,dirDBconst,maskMat.mask,'NDVI')
toc


%% calculate stat
rootDB=kPath.DBSMAP_L3_Global;
dataName='Global';
yrLst=2015:2016;
varWarning= statDBcsvGlobal(rootDB,dataName,yrLst);


%% scan database
rootDB=kPath.DBSMAP_L3_Global;
dataName='Global';
outVar=scanDatabaseGlobal(dataName,1,'dirRoot',rootDB);




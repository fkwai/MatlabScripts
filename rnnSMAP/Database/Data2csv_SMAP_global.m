
% this script will write all data to csv of SMAP CONUS grid, Daily.

global kPath
% maskFile is created by dataset/datasetMask
maskFile=[kPath.SMAP,'maskSMAP_L3.mat'];
yrLst=2000:2016;
dirDB=[kPath.DBSMAP_L3_Global,'Global',filesep];

maskMat=load(maskFile);
lon=maskMat.lon;
lat=maskMat.lat;
mask=maskMat.mask;
ny=length(yrLst);
if ~isdir(dirDB)
    mkdir(dirDB)
end

%% initial Database - each year from 0401 to 0401 next year
initDBcsv_Year(dirDB,yrLst,0401,maskMat)

%% GLDAS
%{
% initial all fields
dirGLDAS=kPath.GLDAS_NOAH_Mat;
fileGLDAS=dir([kPath.GLDAS_NOAH_Mat,'2016',filesep,'*.mat']);
fieldLst=cell(length(fileGLDAS),1);
varLst=cell(length(fileGLDAS),1);
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
%}

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
matFlag=load([kPath.SMAP,'SMAP_L3_flag_AM.mat']);
%PM is same as AM except for vegDense
%matFlag2=load([kPath.SMAP,'SMAP_L3_flag_PM.mat']); 
for k=1:length(matFlag.fieldLst)
    grid2csvDB(matFlag.data(:,:,k),0,dirDBconst,mask,matFlag.fieldLst{k})
end


%% calculate stat
rootDB=kPath.DBSMAP_L3_Global;
dataName='Global';
yrLst=2015:2016;
varWarning= statDBcsv_Year(rootDB,dataName,yrLst);

%%
%{
%% write SMAP
disp('SMAP')
dirDByear=[kPath.DBSMAP_L4,'CONUS',kPath.s];
matFileLst={'SPL4SMGPv3_profile_CONUS','SPL4SMGPv3_surface_CONUS','SPL4SMGPv3_rootzone_CONUS'};
fieldLst={'SMGP_profile','SMGP_surface','SMGP_rootzone'};
for k=1:length(fieldLst)
    tic
    SMAPFile=[kPath.SMAP,matFileLst{k},'.mat'];
    SMAPmat=load(SMAPFile);
    % shrink global to CONUS
    [C,indTemp,indY]=intersect(maskMat.lat,SMAPmat.lat,'stable');
    [C,indTemp,indX]=intersect(maskMat.lon,SMAPmat.lon,'stable');
    dataG=SMAPmat.data(indY,indX,:);
    tIn=SMAPmat.tnum;
    
    grid2csvDB(dataG,tIn,dirDByear,maskMat.mask,fieldLst{k})
    grid2csvDB(dataG,tIn,dirDByear,maskMat.mask,fieldLst{k},'doAnomaly',1)
    toc
end

%% SMAP model constant - see readSMAPflag_script.m
flagTab=readtable([kPath.SMAP,'SMAP_L4_modelConst.csv']);
dirDByear=[kPath.DBSMAP_L4,'CONUS',kPath.s];

for k=1:height(flagTab)
    fieldName=flagTab.DataFieldName{k};
    disp(fieldName)
    if flagTab.Pick(k)==1
        tic
        flagFile=[kPath.SMAP,'SMAP_L4_modelConst',kPath.s,fieldName,'.mat'];
        flagMat=load(flagFile);
        % shrink global to CONUS
        [C,indTemp,indY]=intersect(maskMat.lat,flagMat.lat,'stable');
        [C,indTemp,indX]=intersect(maskMat.lon,flagMat.lon,'stable');
        dataG=flagMat.data(indY,indX,:);
        grid2csvDB(dataG,0,dirDByear,maskMat.mask,fieldName)
        toc
    end
end
%}


%{
%% NDVI
NDVIFile='/mnt/sdb1/Database/GIMMS/avg.tif';
[gridNDVI,refNDVI]=geotiffread(NDVIFile);
lonNDVI=refNDVI.LongitudeLimits(1)+refNDVI.CellExtentInLongitude/2:...
    refNDVI.CellExtentInLongitude:...
    refNDVI.LongitudeLimits(2)-refNDVI.CellExtentInLongitude/2;
latNDVI=[refNDVI.LatitudeLimits(2)-refNDVI.CellExtentInLatitude/2:...
    -refNDVI.CellExtentInLatitude:...
    refNDVI.LatitudeLimits(1)+refNDVI.CellExtentInLatitude/2]';
gridNDVI_int=interp2(lonNDVI,latNDVI,gridNDVI,maskMat.lon,maskMat.lat);
grid2csvDB(gridNDVI_int,0,dirDatabase,maskMat.mask,'NDVI')

%% irrigation
irriFile='/mnt/sdb1/Database/UScrop/cropIrrigation.tif';
[gridIrri,refIrri]=geotiffread(irriFile);
lonIrri=refIrri.LongitudeLimits(1)+refIrri.CellExtentInLongitude/2:...
    refIrri.CellExtentInLongitude:...
    refIrri.LongitudeLimits(2)-refIrri.CellExtentInLongitude/2;
latIrri=[refIrri.LatitudeLimits(2)-refIrri.CellExtentInLatitude/2:...
    -refIrri.CellExtentInLatitude:...
    refIrri.LatitudeLimits(1)+refIrri.CellExtentInLatitude/2]';
gridIrri=double(gridIrri);
gridIrri(gridIrri<0)=0;
vq=interpGridArea(lonIrri,latIrri,gridIrri,maskMat.lon,maskMat.lat,'mean');
grid2csvDB(vq,0,dirDatabase,maskMat.mask,'Irri')
grid2csvDB(vq.^0.5,0,dirDatabase,maskMat.mask,'IrriSq')
%}


% this script will write all data to csv of SMAP CONUS grid, Daily.

global kPath
% maskFile is created by dataset/datasetMask
maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];
yrLst=2000:2017;

dirDB=[kPath.DBSMAP_L3_NA,'CONUS',filesep];

maskMat=load(maskFile);
crd=[maskMat.lat1D,maskMat.lon1D];
mask=maskMat.mask;

%% initial Database - each year from 0401 to 0401 next year
if ~isdir(dirDB)
    mkdir(dirDB)
end
%initDBcsvGlobal(dirDB,yrLst,0401,crd)

%% NLDAS
%productLst={'FORA','FORB','NOAH'};
productLst={'VIC'};
for iP=1:length(productLst)
    productName=productLst{iP};
    % initial all fields
    dirNLDAS=[kPath.NLDAS_Daily,filesep,productName,filesep];
    fileNLDAS=dir([dirNLDAS,filesep,'2016',filesep,'*.mat']);
    fieldLst=cell(length(fileNLDAS),1);
    for k=1:length(fieldLst)
        fieldName=fileNLDAS(k).name(1:end-4);
        fieldLst{k}=fieldName;
    end
    
    % temp only import several fields
    fieldLst={'SOILM_lev1','SOILM_0-100'}
    
    
    yrLstG=[yrLst,yrLst(end)+1];
    tnumG=[datenumMulti(yrLstG(1)*10000+101):datenumMulti(yrLstG(end)*10000+1231)]';
    nt=length(tnumG);
    for iField=1:length(fieldLst)
        % read NLDAS by field
        fieldName=fieldLst{iField};
        matG=cell(length(yrLstG),1);
        parfor iY=1:length(yrLstG)
            yrStr=num2str(yrLstG(iY));
            tic;
            matG{iY}=load([dirNLDAS,num2str(yrLstG(iY)),filesep,fieldName,'.mat']);
            disp(['readNLDAS ',fieldName, ' ',yrStr, ' ', num2str(toc)])            
        end       
        
        tic
        dataG=zeros(224,464,nt);
        for iY=1:length(yrLstG)
            yrStr=num2str(yrLstG(iY));                        
            [C,ind1,ind2]=intersect(matG{iY}.tnum,tnumG);
            dataG(:,:,ind2)=matG{iY}.data;            
        end
        lonG=matG{1}.lon;
        latG=matG{1}.lat;
        lon=maskMat.lon;
        lat=maskMat.lat;
        mask=maskMat.mask;
        
        dataCell=cell(length(yrLst),1);
        for iY=1:length(yrLst)
            yr=yrLst(iY);
            yrStr=num2str(yr);
            dirDByear=[dirDB,yrStr,filesep];
            tnum=csvread([dirDByear,'time.csv']);
            [C,ind1,ind2]=intersect(tnum,tnumG);
            dataCell{iY}=dataG(:,:,ind2);
        end
        disp(['processing ',fieldName,' ', num2str(toc)])
        
        % intp to SMAP grid and write to database
        varName=[fieldName,'_',productName];        
        parfor iY=1:length(yrLst)
            yr=yrLst(iY);
            yrStr=num2str(yr);
            dirDByear=[dirDB,yrStr,filesep];
            tnum=csvread([dirDByear,'time.csv']);
            tic;
            dataTemp=dataCell{iY};
            dataIntp=interpGridArea(lonG,latG,dataTemp,lon,lat);
            %dataIntp=(dataIntp+aF).*mF;
            grid2csvDB(dataIntp,tnum,dirDByear,mask,varName)
            disp(['intp to SMAP ',varName, ' ',yrStr, ' ', num2str(toc)])
        end
    end
end

%{
%% SMAP
matFileLst={[kPath.SMAP,'SMAP_L3_AM.mat'],[kPath.SMAP,'SMAP_L3_PM.mat']};
varLst={'SMAP_AM','SMAP_PM'};
for iD=1:length(matFileLst)
    matSMAP=load(matFileLst{iD});
    dataNA=zeros(length(maskMat.lat),length(maskMat.lon),length(matSMAP.tnum));
    [~,indY1,indY2]=intersect(maskMat.lat,matSMAP.lat,'stable');
    [~,indX1,indX2]=intersect(maskMat.lon,matSMAP.lon,'stable');
    dataNA(indY1,indX1,:)=matSMAP.data(indY2,indX2,:);
    yrLstSMAP=[2015,2016,2017];
    for iY=1:length(yrLstSMAP)
        dirDByear=[dirDB,num2str(yrLstSMAP(iY)),filesep];
        grid2csvDB(dataNA,matSMAP.tnum,dirDByear,maskMat.mask,varLst{iD})
    end
end

%% SMAP flags
dirDBconst=[dirDB,'const',filesep];
flagMat=load([kPath.SMAP,'SMAP_L3_flag_AM.mat']);
[~,indY1,indY2]=intersect(maskMat.lat,flagMat.lat,'stable');
[~,indX1,indX2]=intersect(maskMat.lon,flagMat.lon,'stable');
flagNA=zeros(length(maskMat.lat),length(maskMat.lon),length(flagMat.fieldLst));
flagNA(indY1,indX1,:)=flagMat.data(indY2,indX2,:);

%PM is same as AM except for vegDense
%matFlag2=load([kPath.SMAP,'SMAP_L3_flag_PM.mat']);

% combine [coast, ice, mount, staWater,urban,vegDense]
indComb=[2,3,5,7,8];
dataTemp=flagNA(:,:,indComb);
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
    grid2csvDB(flagNA(:,:,ind),0,dirDBconst,maskMat.mask,flagMat.fieldLst{ind})
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
rootDB=kPath.DBSMAP_L3_NA;
dataName='CONUS';
varWarning= statDBcsvGlobal(rootDB,dataName,2015:2017);
%varWarning= statDBcsvGlobal(rootDB,dataName,2015:2016,'varLst',{'GPM'});

%% scan database
rootDB=kPath.DBSMAP_L3_NA;
dataName='CONUS';
outVar=scanDatabaseGlobal(dataName,1,'dirRoot',rootDB,'stdB',0.001);


%}
rootDB=kPath.DBSMAP_L3_NA;
dataName='CONUS';
varWarning= statDBcsvGlobal(rootDB,dataName,2015:2017,varLst',{'SOILM_lev1','SOILM_0-100');


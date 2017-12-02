
% this script will write all data to csv of SMAP CONUS grid, Daily.


global kPath
% maskFile is created by dataset/script_maskSMAP_CONUS
maskFile=[kPath.SMAP,'maskSMAP_CONUS_L4.mat'];
maskMat=load(maskFile);

%% initial Database and NLDAS
dbNameLst={'85-95','95-05','05-15','CONUS'};
sdLst={19850401,19950401,20050401,20150401};
edLst={19950401,20050401,20150401,20170401};

for kk=4:length(dbNameLst)
    if strcmp(dbNameLst{kk},'CONUS')
        dirDatabase=[kPath.DBSMAP_L4,dbNameLst{kk},kPath.s];
    else
        dirDatabase=[kPath.DBSMAP_L4,'LongTerm_',dbNameLst{kk},kPath.s];
    end
    sd=sdLst{kk};
    ed=edLst{kk};
    initDBcsv( maskMat,dirDatabase,sd,ed )
    
    %% NLDAS - see readNLDAS_Daily_script
    tnum=datenumMulti(sd,1):datenumMulti(ed,1);
    yrLst=year(tnum(1)):year(tnum(end));
    dataLst={'FORA','FORB','NOAH'};
    
    for k=1:length(dataLst)
        dataFolderTemp=[kPath.NLDAS,'NLDAS_Daily',kPath.s,dataLst{k},kPath.s,num2str(2005),kPath.s];
        matFileLst=dir([dataFolderTemp,'*.mat']);
        parfor i=1:length(matFileLst)
            tic
            tnumTemp=[];
            dataTemp=[];
            fieldName=matFileLst(i).name(1:end-4);
            disp(fieldName)
            for yr=yrLst
                disp(['year ',num2str(yr)])
                dataFolder=[kPath.NLDAS,'NLDAS_Daily',kPath.s,dataLst{k},kPath.s,num2str(yr),kPath.s];
                matFile=[dataFolder,matFileLst(i).name];
                matData=load(matFile);
                dataIntp=interpGridArea(matData.lon,matData.lat,matData.data,maskMat.lon,maskMat.lat);
                dataTemp=cat(3,dataTemp,dataIntp);
                tnumTemp=[tnumTemp,matData.tnum];
            end
            grid2csvDB(dataTemp,tnumTemp,dirDatabase,maskMat.mask,fieldName)
            toc
        end
    end
end

%% write SMAP
disp('SMAP')
dirDatabase=[kPath.DBSMAP_L4,'CONUS',kPath.s];
matFileLst={'SPL4SMGPv3_profile_CONUS','SPL4SMGPv3_surface_CONUS','SPL4SMGPv3_rootzone_CONUS'};
fieldLst={'SMGP_profile','SMGP_surface','SMGP_rootzone'};
for k=1:length(fieldLst)
    tic
    SMAPFile=[kPath.SMAP,matFileLst{k},'.mat'];
    SMAPmat=load(SMAPFile);
    % shrink global to CONUS
    [C,indTemp,indY]=intersect(maskMat.lat,SMAPmat.lat,'stable');
    [C,indTemp,indX]=intersect(maskMat.lon,SMAPmat.lon,'stable');
    data=SMAPmat.data(indY,indX,:);
    tIn=SMAPmat.tnum;
    
    grid2csvDB(data,tIn,dirDatabase,maskMat.mask,fieldLst{k})
    grid2csvDB(data,tIn,dirDatabase,maskMat.mask,fieldLst{k},'doAnomaly',1)
    toc
end

%% SMAP model constant - see readSMAPflag_script.m
flagTab=readtable([kPath.SMAP,'SMAP_L4_modelConst.csv']);
dirDatabase=[kPath.DBSMAP_L4,'CONUS',kPath.s];

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
        data=flagMat.data(indY,indX,:);
        grid2csvDB(data,0,dirDatabase,maskMat.mask,fieldName)
        toc
    end
end

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













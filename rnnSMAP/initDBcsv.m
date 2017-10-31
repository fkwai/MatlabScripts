function initDBcsv( maskMat,dirDB,sd,ed )
%initialize database to trained in torch

% input
% maskMat - Example: kPath.SMAP,'maskSMAP_CONUS.mat', created by dataset/script_maskSMAP_CONUS
% dirDB - directory of database, Example: kPath.DBSMAP_L3_CONUS
% sd - start date, yyyymmdd
% ed - end date, yyyymmdd


%% initial Database
if ~isdir(dirDB)
    mkdir(dirDB)
end

crdFile=[dirDB,'crd.csv'];
crd=[maskMat.lat1D,maskMat.lon1D];
dlmwrite(crdFile,crd,'precision',12);

timeFile=[dirDB,'time.csv'];
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';
dlmwrite(timeFile,tnum,'precision',12);

end


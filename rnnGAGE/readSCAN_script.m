% read SCAN data and save to matfile

global kPath
tab=readtable([kPath.SCAN,'nwcc_inventory_CONUS.csv']);
siteIdLst=tab.stationId;
siteSCAN=[];
for k=1:length(siteIdLst)
    siteTemp=readSCAN_site(siteIdLst(k));
    if ~isempty(siteTemp)
        siteTemp.crd=[tab.lat(k),tab.lon(k)];        
        siteSCAN=[siteSCAN;siteTemp];
    end
end
saveFile=[kPath.SCAN,filesep,'siteSCAN_CONUS.mat'];
save(saveFile,'siteSCAN');
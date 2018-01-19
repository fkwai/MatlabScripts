% after read core stations (readCoreSite_script.m), combine those
% stations to SMAP pixel according to given voroni matrix.

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];

%% read all sites
siteIDLst=[0401,0901,0902,1601,1602,1603,1604,1606,1607,2601,2701,4801];
resStrLst={'09','36'};
for k=1:length(resStrLst)
    resStr=resStrLst{k};
    sitePixel=[];
    for kk=1:length(siteIDLst)
        siteID=siteIDLst(kk);
        sitePixelTemp=coreSite2pixel(siteID, resStr);
        sitePixel=[sitePixel;sitePixelTemp];
    end
    saveFile=[dirCoreSite,'siteMat',filesep,'sitePix_',resStr,'.mat'];
    save(saveFile,'sitePixel')
end


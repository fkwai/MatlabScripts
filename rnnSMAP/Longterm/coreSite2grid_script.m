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
        sitePixelTemp=coreSite2grid(siteID, resStr);
        sitePixel=[sitePixel;sitePixelTemp];
    end
    
    %% remove 2701 and modify version
    indRM=[];
    versionLst=[];
    for kk=1:length(sitePixel)
        if strcmp(sitePixel(kk).ID(1:4),'2701') % 2701 is out of bound
            indRM=[indRM,kk];
        end
        if kk>1
            versionLst(kk)=sum(ismember({sitePixel(1:kk-1).ID},sitePixel(kk).ID));
        end
    end
    for kk=1:length(sitePixel)
        if versionLst(kk)>0
            sitePixel(kk).ID=[sitePixel(kk).ID,'0',num2str(versionLst(kk)+1)];
        end
    end
    sitePixel(indRM)=[];

    saveFile=[dirCoreSite,'siteMat',filesep,'sitePix_',resStr,'.mat'];
    save(saveFile,'sitePixel')
end


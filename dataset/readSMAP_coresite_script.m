
% read SMAP core validation sites of SMAP. Database from a friend

dirCore='/mnt/sdb/Database/SMAP/SMAP_VAL/coresite/';
siteFolderLst=dir([dirCore,'*_*']);
siteFolderLst=siteFolderLst([siteFolderLst.isdir]);

%% get site Lst
nSite=length(siteFolderLst);
siteIdLst=zeros(nSite,1);
siteNameLst=cell(nSite,1);
for k=1:nSite
    C=strsplit(siteFolderLst(k).name,'_');
    siteIdLst(k)=str2num(C{1});
    siteNameLst{k}=C{2};
end

%% for each site
siteLst=[];
for k=1:nSite
    siteID=siteIdLst(k);
    siteIdStr=sprintf('%04d',siteID);
    siteName=siteNameLst{k};
    disp(['reading site: ', siteIdStr,' ',siteName])
    tic
    
    siteFolder=[dirCore,filesep,siteIdStr,'_',siteName,filesep,'dataqc',filesep];
    staFolderLst=dir([siteFolder,filesep,siteIdStr,'*']);
    nSta=length(staFolderLst);
    stationLst=[];
    for kk=1:nSta        
        staID=staFolderLst(kk).name(5:7);
        disp(['reading station: ', staID])
        staFolder=[siteFolder,filesep,staFolderLst(kk).name,filesep];
        temp=readSMAP_coresite(staFolder);
        temp.stationID=staID;
        temp.siteID=siteID;
        stationLst=[stationLst;temp];
    end
    site.station=stationLst;
    site.siteID=siteID;    
    site.siteName=siteName;
    siteLst=[siteLst;site];
    toc
end

site=siteLst;
save(['/mnt/sdb/Database/SMAP/SMAP_VAL/coreSite.mat'],'site','-v7.3')

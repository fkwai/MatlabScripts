
% read in-situ database, which also called as core validation sites of
% SMAP. Database downloaded from in NSIDC (see gitbook)

global kPath

%% read sites
% 2015.04.01 has all SMP and SMPE in-situ data.
% 2015.04.13 has all SMA and SMAP in-situ data.
siteFolder=[kPath.SMAP_VAL,'NSIDC-0712.001',filesep,'2015.04.01'];
siteTabFile=[kPath.SMAP_VAL,'NSIDC-0712.001',filesep,'siteLst.csv'];

fileLst=dir([siteFolder,filesep,'*.txt']);
fileNameLst={fileLst.name};

site=[];
for k=1:length(fileNameLst)
    fileName=[siteFolder,filesep,fileNameLst{k}];
    site=[site;readSMAPval(fileName)];
end
siteTab=readtable(siteTabFile);

%% pick SMP sites
%ind=30; % siteID = 1607, version = R13080
matSMAP=load([kPath.SMAP,'SMAP_L3_CONUS.mat']);
siteNSIDC=[];
for ind=1:length(site)
    indTab=find(site(ind).ID==siteTab.SiteID);
    if strcmp(site(ind).product,'SMAPL2SMP') &&...
            site(ind).gridScale==36 && ...
            ~isempty(indTab)
        siteTemp=[];
        %% find corresponding SMAP cell
        lat=siteTab.Latitude(indTab);
        lon=siteTab.Longitude(indTab);
        [C,indY]=min(abs(matSMAP.lat-lat));
        [C,indX]=min(abs(matSMAP.lon-lon));
        vSMAP=permute(matSMAP.data(indY,indX,:),[3,1,2]);
        tSMAP=matSMAP.tnum;
        
        %% save to mat
        indHead=find(strcmp(site(ind).head,'WASM'));
        vSite=site(ind).data(:,indHead);
        tFieldLst={'Yr','Mo','Day','Hr','Min'};
        for i=1:length(tFieldLst)
            tField=tFieldLst{i};
            tStr.(tField)=site(ind).data(:,strcmp(site(ind).head,tField));
        end
        tSite=datenum(tStr.Yr,tStr.Mo,tStr.Day,tStr.Hr,tStr.Min,zeros(length(tStr.Yr),1));
        
        siteTemp.vSite=vSite;
        siteTemp.tSite=tSite;
        siteTemp.vSMAP=vSMAP;
        siteTemp.tSMAP=tSMAP;
        siteTemp.siteID=site(ind).ID;
        siteTemp.version=site(ind).version;
        siteTemp.indY_CONUS=indY;
        siteTemp.indX_CONUS=indX;
        siteNSIDC=[siteNSIDC;siteTemp];
    end
end
siteMatFile=[kPath.SMAP_VAL,'NSIDC-0712.001',filesep,'siteNSIDC.mat'];
save(siteMatFile,'siteNSIDC')

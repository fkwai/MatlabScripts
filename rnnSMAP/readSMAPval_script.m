
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

%% find corresponding SMAP cell
ind=30; % siteID = 1607, version = R13080
lat=siteTab.Latitude(siteTab.SiteID==site(ind).ID);
lon=siteTab.Longitude(siteTab.SiteID==site(ind).ID);

matSMAP=load([kPath.SMAP,'SMAP_L3_CONUS.mat']);
[c,indY]=min(abs(matSMAP.lat-lat));
[c,indX]=min(abs(matSMAP.lon-lon));

%% compare time series
indHead=find(strcmp(site(ind).head,'WASM'));
ySite=site(ind).data(:,indHead);
Y=site(ind).data(:,2);
M=site(ind).data(:,3);
D=site(ind).data(:,4);
tSite=datenum(Y,M,D);
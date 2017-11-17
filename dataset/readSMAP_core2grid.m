
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
siteID=1601;
soilLayer=[0.05];
siteIDstr=sprintf('%04d',siteID);

%% read site
saveMatFile=[dirCoreSite,'siteMat',filesep,'site_',siteIDstr,'.mat'];
if exist(saveMatFile,'file')
    load(saveMatFile)
else
    site = readSMAP_coresite(siteID);
end

%% read coordinate of site 
version=4;
versionStr=sprintf('%02d',version);
dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];
% read crd
fileCrd=[folderSiteInfo,siteIDstr,'_COORD_v',versionStr,'.csv'];
tabCrd=readtable(fileCrd);
lonSite=tabCrd.Longitude;
latSite=tabCrd.Latitude;

%% find smap grid
maskSMAP=load('/mnt/sdb/rnnSMAP/maskSMAP_CONUS.mat');
lonC=mean(lonSite(indSite));
latC=mean(latSite(indSite));
lonSMAP=maskSMAP.lon;
latSMAP=maskSMAP.lat;
[C,indX]=min(abs(lonSMAP-lonC));
[C,indY]=min(abs(latSMAP-latC));
indSMAP=maskSMAP.maskInd(indY,indX);

%% integrad to SMAP
folderWeight=[folderSiteInfo,'voronoi',filesep];
dirWeight=dir([folderWeight,'voronoi_',siteIDstr,'36',versionStr,'*.txt']);
tabWeight=csvread([folderWeight,dirWeight(1).name],1,0);
w=tabWeight(2,:);
ind=tabWeight(1,:);
v=site.SM_05.v(:,ind);
t=site.SM_05.t;
vSite0=sum(v.*repmat(w,[size(v,1),1]),2);
vSite=nanmean(v.*repmat(w,[size(v,1),1]),2).*length(w);

plot(t,vSite,'b-');hold on
plot(t,vSite0,'r-');hold off

% plot
%{
x1=(lonSMAP(indX-1)+lonSMAP(indX))/2;
y1=(latSMAP(indY+1)+latSMAP(indY))/2;
x2=(lonSMAP(indX+1)+lonSMAP(indX))/2;
y2=(latSMAP(indY-1)+latSMAP(indY))/2;
plot([x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1],'-k');hold on
plot(lonSite(indSite),latSite(indSite),'*r');hold off
%}

%% read SMAP and LSTM
SMAP=csvread([kPath.DBSMAP_L3,filesep,'CONUS',filesep,'SMAP.csv']);

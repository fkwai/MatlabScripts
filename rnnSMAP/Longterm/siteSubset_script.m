
% create a subset contains L4v4f1 + Core Site + CRN sites
global kPath

%% load site crd
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep,'siteMat',filesep];
mat=load([dirCoreSite,'sitePixel_root_unshift.mat']);
sitePixel=mat.sitePixel;
mat=load([dirCoreSite,'sitePixel_root_shift.mat']);
sitePixel_shift=mat.sitePixel;
siteMat_Core=[sitePixel;sitePixel_shift];

temp=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
siteMat_CRN=temp.siteCRN;

crdSiteLst=[];
for k=1:length(siteMat_Core)
    crdSiteLst=[crdSiteLst;siteMat_Core(k).crdC];
end
for k=1:length(siteMat_CRN)
    crdSiteLst=[crdSiteLst;siteMat_CRN(k).lat,siteMat_CRN(k).lon];
end

%% find index of site
rootDB=kPath.DBSMAP_L4;
refName='CONUS';
crd=csvread([rootDB,refName,filesep,'crd.csv']);
indLst=[];
distLst=[];
for k=1:size(crdSiteLst,1)
    crdSite=crdSiteLst(k,:);
    [C,ind]=min(sum(abs(crd-crdSite),2));
    disp([num2str(k),': ',num2str(C,3)])
    indLst=[indLst;ind];
    distLst=[distLst;C];
end
indPick=find(distLst<0.1);
indSubSite=unique(indLst(indPick));

%% find index of rootzone CONUSv4f1 
indSubCONUS=subsetSMAP_interval(4,1,'CONUS_L4','writeSubFile',0);
indSub=[indSubSite;indSubCONUS];
indSub=unique(indSub);

%% do subset
subsetName='CONUSv4f1wSite';
subsetSMAP_indSub(indSub,rootDB,'CONUS',subsetName)
subsetSplit(subsetName,'rootDB',rootDB)

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

crdSiteLst_Core=[];
crdSiteLst_CRN=[];
for k=1:length(siteMat_Core)
    crdSiteLst_Core=[crdSiteLst_Core;siteMat_Core(k).crdC];
end
for k=1:length(siteMat_CRN)
    crdSiteLst_CRN=[crdSiteLst_CRN;siteMat_CRN(k).lat,siteMat_CRN(k).lon];
end

%%
productName='rootzone';
if strcmp(productName,'surface')
    rootDB=kPath.DBSMAP_L3_NA;
    refName='CONUS';
    caseName='NA_L3';
    subsetName='CONUSv4f1wSite';
    nv=4;
    nf=1;
    distThe=1;
elseif strcmp(productName,'rootzone')
    rootDB=kPath.DBSMAP_L4_NA;
    refName='CONUS';
    caseName='NA_L4';
    subsetName='CONUSv16f1wSite';
    nv=16;
    nf=1;
    distThe=1;
end

%% find index of site
crd=csvread([rootDB,refName,filesep,'crd.csv']);
for kk=1:2
    if kk==1
        crdSiteLst=crdSiteLst_Core;
    elseif kk==2
        crdSiteLst=crdSiteLst_CRN;
    end
    indLst=zeros(size(crdSiteLst,1),1);
    distLst=zeros(size(crdSiteLst,1),1);
    for k=1:size(crdSiteLst,1)
        crdSite=crdSiteLst(k,:);
        [C,ind]=min(sum(abs(crd-crdSite),2));
        disp([num2str(k),': ',num2str(C,3)])
        indLst(k)=ind;
        distLst(k)=C;
    end
    if kk==1
        indSub_Core=unique(indLst(distLst<distThe));
    elseif kk==2
        indSub_CRN=unique(indLst(distLst<distThe));
    end
end

%% find index of CONUSv4f1 / CONUSv16f1 and do subset
indSubCONUS=subsetSMAP_interval(nv,nf,caseName,'writeSubFile',0);
indSub=[indSub_Core;indSub_CRN;indSubCONUS];
indSub=unique(indSub);
subsetSMAP_indSub(indSub,rootDB,'CONUS',subsetName)
msg=subsetSplitGlobal(subsetName,'rootDB',rootDB);

subsetSMAP_indSub(indSub_Core,rootDB,'CONUS','CoreSite')
msg1=subsetSplitGlobal('CoreSite','rootDB',rootDB);
subsetSMAP_indSub(indSub_CRN,rootDB,'CONUS','CRN')
msg2=subsetSplitGlobal('CRN','rootDB',rootDB);


% find referencing SMAP grid index, create subset and run LSTM
global kPath

dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep,'siteMat',filesep];

%% surface
mat=load([dirCoreSite,'sitePixel_surf.mat']);
sitePixel=mat.sitePixel;
mat=load([dirCoreSite,'sitePixel_surf_shifted.mat']);
sitePixel_shift=mat.sitePixel;
siteLst=[sitePixel;sitePixel_shift];
crdSiteLst=zeros(length(siteLst),2);
for k=1:length(siteLst)
    crdSiteLst(k,:)=siteLst(k).crdC;
end
dataNameLst={'LongTerm8595','LongTerm9505','LongTerm0515','CONUS'};
suffix='_Core';
outName='LongTermCore';
siteSubset(crdSiteLst,dataNameLst,outName,'suffix',suffix)

% dataNameLst_site=cell(size(dataNameLst));
% for k=1:length(dataNameLst_site)
%     dataNameLst_site{k}=[dataNameLst{k},suffix];
% end
% combineDB_time( dataNameLst_site,outName)

% CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTermCore -timeOpt 0 -drMode 100

%% Rootzone 
mat=load([dirCoreSite,'sitePixel_root.mat']);
sitePixel=mat.sitePixel;
mat=load([dirCoreSite,'sitePixel_root_shifted.mat']);
sitePixel_shift=mat.sitePixel;
siteLst=[sitePixel;sitePixel_shift];
crdSiteLst=zeros(length(siteLst),2);
for k=1:length(siteLst)
    crdSiteLst(k,:)=siteLst(k).crdC;
end
rootDB=kPath.DBSMAP_L4;
suffix='_Core';

% CONUS full 
dataNameLst={'LongTerm8595','LongTerm9505','LongTerm0515','CONUS'};
outName='LongTermCore';
siteSubset(crdSiteLst,dataNameLst,outName,'rootDB',rootDB,'suffix',suffix)

% dataNameLst_site=cell(size(dataNameLst));
% for k=1:length(dataNameLst_site)
%     dataNameLst_site{k}=[dataNameLst{k},suffix];
% end
% combineDB_time( dataNameLst_site,outName,'rootDB',rootDB)

% CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -test LongTermCore -timeOpt 0 -drMode 100 -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4_CONUS/

% CONUS v4f1
dataNameLst={'LongTerm8595v4f1','LongTerm9505v4f1','LongTerm0515v4f1','CONUSv4f1'};
outName='LongTermCorev4f1';
siteSubset(crdSiteLst,dataNameLst,outName,'rootDB',rootDB,'suffix',suffix)

% dataNameLst_site=cell(size(dataNameLst));
% for k=1:length(dataNameLst_site)
%     dataNameLst_site{k}=[dataNameLst{k},suffix];
% end
% combineDB_time( dataNameLst_site,outName,'rootDB',rootDB)

%CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -test LongTermCorev4f1 -timeOpt 0 -drMode 100 -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4_CONUS/

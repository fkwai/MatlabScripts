
% find referencing SMAP grid index, create subset and run LSTM
global kPath

temp=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
siteMat=temp.siteCRN;
crdSiteLst=zeros(length(siteMat),2);
for k=1:length(siteMat)
    crdSiteLst(k,:)=[siteMat(k).lat,siteMat(k).lon];
end
suffix='_CRN';


%% surface
dataNameLst={'LongTerm8595','LongTerm9505','LongTerm0515','CONUS'};
outName='LongTerm_CRN';
siteSubset(crdSiteLst,dataNameLst,outName,'suffix',suffix)
subsetSplit('CONUS_CRN','varLst',{'SMAP'},'varConstLst',{});


% CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTerm_CRN -timeOpt 0 -drMode 100

%% Rootzone
rootDB=kPath.DBSMAP_L4;
% CONUS full
dataNameLst={'LongTerm8595','LongTerm9505','LongTerm0515','CONUS'};
outName='LongTerm_CRN';
siteSubset(crdSiteLst,dataNameLst,outName,'rootDB',rootDB,'suffix',suffix)
subsetSplit('CONUS_CRN','varLst',{'SMGP_rootzone'},'varConstLst',{},'dirRoot',rootDB);


% CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -test LongTerm_CRN -timeOpt 0 -drMode 100 -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4_CONUS/

% CONUS v4f1
dataNameLst={'LongTerm8595v4f1','LongTerm9505v4f1','LongTerm0515v4f1','CONUSv4f1'};
outName='LongTermv4f1_CRN';
siteSubset(crdSiteLst,dataNameLst,outName,'rootDB',rootDB,'suffix',suffix)
subsetSplit('CONUSv4f1_CRN','varLst',{'SMGP_rootzone'},'varConstLst',{},'dirRoot',rootDB);


%CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -test LongTermv4f1_CRN -timeOpt 0 -drMode 100 -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4_CONUS/

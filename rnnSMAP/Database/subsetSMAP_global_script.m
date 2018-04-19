
%  a script summarized all steps to create existing subsets

%% interval - write Database
global kPath
maskFile=[kPath.SMAP,'maskSMAP_L3.mat'];
rootDB=[kPath.DBSMAP_L3_Global];
dbName='Global';
 vecV=[4];
 vecF=[4];
for k=1:length(vecV)
    interval=vecV(k);
    offset=vecF(k);
    subsetSMAP_interval(interval,offset,'Global_L3');
    subsetName=[dbName,'v',num2str(interval),'f',num2str(offset)];
    msg=subsetSplitGlobal(subsetName);
end

%% get CONUS subset
dbName='Globalv4f4';
crd=csvread([kPath.DBSMAP_L3_Global,dbName,filesep,'crd.csv']);
bb=[-125,-66;25,50];
indSub=find(crd(:,1)>bb(2,1)&crd(:,1)<bb(2,2)&crd(:,2)>bb(1,1)&crd(:,2)<bb(1,2));
subsetSMAP_indSub(indSub,'Globalv4f4','CONUSv4f4',kPath.DBSMAP_L3_Global);
msg=subsetSplitGlobal('CONUSv4f4');

crd1=csvread('/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3/CONUSv4f4/crd.csv');

crd2=csvread('/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3_test/CONUSv4f1/crd.csv');
%plot(crd(indSub,2),crd(indSub,1),'ro');hold on
plot(crd1(:,2),crd1(:,1),'ro');hold on
plot(crd2(:,2),crd2(:,1),'b*');hold off

%% single variable
msg1=subsetSplitGlobal('Globalv4f4','varLst',{'GPM'},'varConstLst',[],'yrLst',2000:2016);
msg2=subsetSplitGlobal('CONUSv4f4','varLst',{'GPM'},'varConstLst',[],'yrLst',2000:2016);

% CUDA_VISIBLE_DEVICES=0 th trainLSTM.lua -var varLst_Noah -out Globalv8f1_Noah_GPM -train Globalv8f1

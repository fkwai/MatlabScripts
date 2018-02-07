
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];

%% load site
resStr='36';
load([dirCoreSite,'siteMat',filesep,'sitePix_',resStr,'.mat']);

%% fine SMAP CONUS index
maskSMAP=load(kPath.maskSMAP_CONUS);
indSMAPLst=[];
for k=1:length(sitePixel)
    [C1,indX]=min(abs(maskSMAP.lon-sitePixel(k).crdC(2)));
    [C2,indY]=min(abs(maskSMAP.lat-sitePixel(k).crdC(1)));
    disp([sitePixel(k).ID,': ',num2str(C1,3),' ',num2str(C2,3)])
    indSMAP=maskSMAP.maskInd(indY,indX);
    indSMAPLst=[indSMAPLst;indSMAP];
end
indSubset=unique(indSMAPLst);


%% do subset of those pixels and run test
%{
indSubset=unique(indSMAPLst);
rootNameLst={'CONUS','LongTerm8595','LongTerm9505','LongTerm0515'};
for k=1:length(rootNameLst)
    rootName=rootNameLst{k};
    subsetFile=[kPath.DBSMAP_L3,'Subset',filesep,rootName,'site.csv'];
    dlmwrite(subsetFile,rootName,'');
    dlmwrite(subsetFile,indSubset,'-append');
end

for k=1:length(rootNameLst)
    rootName=rootNameLst{k};
    subsetName=[rootName,'site'];
    if strcmp(rootName,'CONUS')
        subsetSplit(subsetName,'dirRoot',kPath.DBSMAP_L3);
    else
        subsetSplit(subsetName,'dirRoot',kPath.DBSMAP_L3,'varLst','varLst_Noah');
    end
end
%}

% run testLSTM on those pixels then
%{
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test CONUSsite -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTerm8595site -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTerm9505site -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTerm0515site -timeOpt 0
%}

%% read SMAP and LSTM
rootOut=kPath.OutSMAP_L3;
rootDB=kPath.DBSMAP_L3;
outName='fullCONUS_Noah2yr';
target='SMAP';
dataName='CONUSsite';
SMAP.v=readDatabaseSMAP(dataName,target,rootDB);
SMAP.t=csvread([rootDB,dataName,filesep,'time.csv']);
SMAP.crd=csvread([rootDB,dataName,filesep,'crd.csv']);

testLst={'LongTerm8595site','LongTerm9505site','LongTerm0515site','CONUSsite'};
LSTM.v=[];
LSTM.t=[];
for k=1:length(testLst)
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',target);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM.v=[LSTM.v;vTemp(2:end,:)];
        LSTM.t=[LSTM.t;tTemp(2:end,:)];
    end
end
LSTM.crd=csvread([rootDB,testLst{1},filesep,'crd.csv']);


%% find index of smap and LSTM
nSite=length(sitePixel);
indTest=zeros(nSite,1);
for k=1:nSite
    [C,indTemp]=min(sum(abs(SMAP.crd-sitePixel(k).crdC),2));
    if C>0.3
        error(['check if corresponding pixel is found: ',num2str(k)])
    end
    indTest(k)=indTemp;
end

%% load predictors
testLst={'LongTerm8595site','LongTerm9505site','LongTerm0515site','CONUSsite'};
varLst={'TMP_2','APCP','DSWRF','DLWRF','SPFH_2','UGRD_10','VGRD_10',...
   'SOILM_0-10','LSOIL_0-10','TSOIL_0-10','MSTAV_0-100','BGRUN','EVP','PEVPR','SHTFL'};Pred.v=[];
Pred.t=[];
for k=1:length(testLst)
    xData=[];
    for kk=1:length(varLst)
        [xDataTemp,xStat,xDataNorm]=readDatabaseSMAP(testLst{k},varLst{kk});
        xData=cat(3,xData,xDataNorm);
    end
    tTemp=csvread([kPath.DBSMAP_L3,testLst{k},filesep,'time.csv']);    
    if k>1
        Pred.v=[Pred.v;xData(2:end,:,:)];
        Pred.t=[Pred.t;tTemp(2:end,:)];
    end    
end

pSite=[1;3;6;9;13;18;22;23;26];
pRate=[1;3;1;1;3;1;3;3;3];
pName={'Reynolds Creek','Carman','Walnut Gulch',...
    'Little Washita','Fort Cobb','Little River',...
    'St. Josephs','South Fork','TxSON'};

%% ARMA
ARMA.v=zeros(size(LSTM.v));
ARMA.t=LSTM.t;
for k=1:size(SMAP.v,2)
    tTrain=datenumMulti(20150401);
    indTrain=find(LSTM.t>=tTrain);
    x0=permute(Pred.v(indTrain,k,:),[1,3,2]);
    x1=permute(Pred.v(:,k,:),[1,3,2]);
    y0=SMAP.v(:,k);
    ns=3;
    yp=ARMAts(x0,y0,x1,ns);
    ARMA.v(:,k)=yp;
end

%% save files
saveFile=[dirCoreSite,'siteMat',filesep,'siteSMAP_',resStr,'.mat'];
save(saveFile,'SMAP','LSTM','ARMA','indTest')





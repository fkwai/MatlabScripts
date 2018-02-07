
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];

%% load LSTM, SMAP, and site
resStr='36';
load([dirCoreSite,'siteMat',filesep,'sitePix_',resStr,'.mat']);
load([dirCoreSite,'siteMat',filesep,'siteSMAP_',resStr,'.mat']);

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
saveFile=[dirCoreSite,'siteMat',filesep,'siteSMAP_',resStr,'.mat'];
save(saveFile,'SMAP','LSTM','ARMA','indTest')


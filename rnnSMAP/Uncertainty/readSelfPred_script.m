
global kPath
rootOut=kPath.OutSelf_L3;
rootDB=kPath.DBSMAP_L3;
dataName='CONUSv4f1';
outName='CONUSv4f1';

%% read option
opt = readRnnOpt( outName,rootOut );
varLst=readVarLst([rootDB,'Variable',filesep,opt.var,'.csv']);
epoch=opt.nEpoch;


%inputMat=[];
%outputMat=[];
inputNormMat=[];
outputNormMat=[];
%statMat=[];

%% read predictors
for k=1:length(varLst)
    var=varLst{k};
    [xData,xStat,xDataNorm] = readDB_SMAP(dataName,var);
    inputNormMat=cat(3,inputNormMat,xDataNorm);
end

%% read predictions
for k=1:length(varLst)
    var=varLst{k};
    outFile=[rootOut,filesep,outName,filesep,'test_',dataName,'_',var,'_t1_epoch',num2str(epoch),'.csv'];
    d1=csvread(outFile);
    outFile=[rootOut,filesep,outName,filesep,'test_',dataName,'_',var,'_t2_epoch',num2str(epoch),'.csv'];
    d2=csvread(outFile);
    outputNormMat=cat(3,outputNormMat,[d1;d2]);
    %temp=tempNorm.*statMat(4,k)+statMat(3,k);
    %outputMat=cat(3,outputMat,temp);
end

%%
ix=1;
ig=randi([1,size(inputNormMat,2)]);
plot(1:size(inputNormMat,1),inputNormMat(:,ig,ix),'b');hold on
plot(1:size(outputNormMat,1),outputNormMat(:,ig,ix),'r');hold off
corr(inputNormMat(:,ig,ix),outputNormMat(:,ig,ix))

outStat=mean((outputNormMat-inputNormMat).^2,3).^0.5;

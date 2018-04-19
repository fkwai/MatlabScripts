
dataName='CONUSv4f1';
outName='CONUSv4f1_Forcing7_LSOIL';
outName_Self='CONUSv4f1';
epoch=300;
timeOpt=2;

yLSTM= readRnnPred(outName,dataName,epoch,timeOpt);
[ySMAP,~,~] = readDB_SMAP(dataName,'SMAP');
ySelf=readSelfPred(outName_Self,dataName);

if timeOpt==1
    ySMAP=ySMAP(1:366,:);
elseif timeOpt==2
    ySMAP=ySMAP(367:732,:);
elseif timeOpt==3
    ySMAP=ySMAP(1:732,:);
elseif timeOpt==0
    ySMAP=ySMAP;
end

yStat=abs(yLSTM-ySMAP);

a=nanmean(yStat)';
b=nanmean(ySelf)';
ind=~isnan(a)&~isnan(b);
corr(a(ind),b(ind))


ig=randi([1,size(yLSTM,2)]);
hold on
yyaxis left
plot(1:size(yLSTM,1),yLSTM(:,ig),'b');
plot(1:size(ySMAP,1),ySMAP(:,ig),'ko');
yyaxis right
plot(1:size(ySelf,1),ySelf(:,ig),'r');
hold off


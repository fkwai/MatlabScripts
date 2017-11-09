
outFolder='E:\Kuai\rnnSMAP_outputs\fullCONUS\fullCONUS_Noah2yr\';
saveFolder='E:\Kuai\rnnSMAP_result\hindcast\';

%% init
tStrLst={'85-95','95-05','05-15'};
sd=19850401;
ed=20150401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';
crd=csvread('H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\CONUS\crd.csv');

%% merge hindcast
data=[];
for k=1:length(tStrLst)
    k
    fileName=[outFolder,filesep,'test_LongTerm_',tStrLst{k},'_t0_epoch500.csv'];
    temp=csvread(fileName);
    if k~=1 % a bug...
        data=[data;temp(2:end,:)];
    else
        data=[data;temp];
    end
end

%% save hindcast 
statFile=['H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\CONUS\SMAP_stat.csv'];
stat=csvread(statFile);
dataOut=(data).*stat(4)+stat(3);
if ~isdir(saveFolder)
    mkdir(saveFolder)
end
dataFile=[saveFolder,'hindcastSMAP_30yr.csv'];
crdFile=[saveFolder,'hindcastSMAP_30yr_crd.csv'];
timeFile=[saveFolder,'hindcastSMAP_30yr_time.csv'];
dlmwrite(dataFile,dataOut,'precision',8);
dlmwrite(timeFile,datenumMulti(tnum,2),'precision',12);
dlmwrite(crdFile,crd,'precision',12);

%% plot
k1=randi([1,size(crd,1)]);
k2=randi([1,size(crd,1)]);
plot(tnum,dataOut(:,k1));hold on
plot(tnum,dataOut(:,k2),'r');hold off
datetick('x')



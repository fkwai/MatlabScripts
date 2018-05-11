
global kPath
rootOut=kPath.OutSigma_L3_NA;
rootDB=kPath.DBSMAP_L3_NA;
outName='CONUSv4f1wSite_soilM_2017';
dataName1='CONUSv4f1wSite';
dataName2='CoreSite';

[xData1,~,crd1,time1] = readDB_Global(dataName1,'SMAP_AM','yrLst',[2017:2017],'rootDB',rootDB);
dataOut1=readRnnPred(outName,dataName1,500,[2017,2017],'rootOut',rootOut,'rootDB',rootDB);

[xData2,~,crd2,time2] = readDB_Global(dataName2,'SMAP_AM','yrLst',[2015:2017],'rootDB',rootDB);
dataOut2=readRnnPred(outName,dataName2,500,[2015,2017],'rootOut',rootOut,'rootDB',rootDB);

[ind1,ind2]=intersectCrd(crd1,crd2);

d1=dataOut1(:,ind1);
d2=dataOut2(:,ind2);

ind=randi([1,527]);
plot(time1,dataOut1(:,ind),'b-');hold on
plot(time1,xData1(:,ind),'ro');hold off


%%
global kPath
rootOut=kPath.OutSigma_L3_NA;
rootDB=kPath.DBSMAP_L3_NA;
outName='CONUSv4f1_001_200';
dataName='CONUSv4f1';

[xData,~,crd,time] = readDB_Global(dataName,'SMAP_AM','yrLst',[2015:2015],'rootDB',rootDB);
dataOut=readRnnPred_sigma(outName,dataName,500,[2015,2015],'rootOut',rootOut,'rootDB',rootDB);

ind=randi([1,412]);
plot(time,dataOut(:,ind),'b-');hold on
plot(time,xData(:,ind),'ro');hold off

%%
file1='/mnt/sdb1/rnnSMAP/output_SMAPsigma_NA/CoreSite_soilM/testSigma_CoreSite_2017_2017_ep100.csv'
file2='/mnt/sdb1/rnnSMAP/output_SMAPsigma_NA/CoreSite_soilM2/testSigma_CoreSite_2017_2017_ep100.csv'
data1=csvread(file1);
data2=csvread(file2);
ind=randi([1,16]);
plot(1:365,data1(:,ind),'-b');hold on
plot(1:365,data2(:,ind),'-r');hold off

plot(1:365,data1(:,randi([1,16])));
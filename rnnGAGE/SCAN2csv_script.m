
%% initial Database
dbFolder=[kPath.DBSCAN,'CONUS',kPath.s];
dataFolder=[kPath.SCAN,'Daily',kPath.s];

tab=readtable([kPath.SCAN,'nwcc_inventory_CONUS.csv']);
crdFile=[dbFolder,'crd.csv'];
crd=[tab.lat,tab.lon];
dlmwrite(crdFile,crd,'precision',12);

timeFile=[dbFolder,'time.csv'];
sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';
nt=length(tnum);
dlmwrite(timeFile,tnum,'precision',12);


%% SCAN data
% hard code depth list
depthLst=[2,4,6,8,12,15,20,40,60,80];
nDepth=length(depthLst);
yrLst=year(sdn):year(edn);
sidLst=tab.stationId;
nS=length(sidLst);

indS=zeros(nS,1);
soilM_All=zeros(nS,nt,nDepth)*nan;

for k=1:nS
    [soilM_tmp,tnum_tmp]=readSCAN_DB(sidLst(k),2015:2017);
    [C,indT0,indT]=intersect(tnum,tnum_tmp);
    soilM_All(k,indT0,:)=soilM_tmp(indT,:);
end
matValid=permute(mean(~isnan(soilM_All),2),[1,3,2]);

%% write SCAN to csv
for k=1:nDepth
    output=soilM_All(:,:,k);
    output(isnan(output))=-9999;
    dataFile=[dbFolder,kPath.s,'soilM_SCAN_',num2str(depthLst(k)),'.csv'];
    dlmwrite(dataFile,output,'precision',8);

    % stat
    statFile=[dbFolder,kPath.s,'soilM_SCAN_',num2str(depthLst(k)),'_stat.csv'];
    vecOutput=output(:);
	vecOutput(vecOutput==-9999)=[];
	perc=10;
	lb=prctile(vecOutput,perc);
	ub=prctile(vecOutput,100-perc);
	data80=vecOutput(vecOutput>=lb &vecOutput<=ub);
	m=mean(data80);
	sigma=std(data80);
	stat=[lb;ub;m;sigma];
    dlmwrite(statFile, stat,'precision',8);
end




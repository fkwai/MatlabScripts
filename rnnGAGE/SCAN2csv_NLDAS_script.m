dbFolder=[kPath.DBSCAN,'CONUS',kPath.s];
tab=readtable([kPath.SCAN,'nwcc_inventory_CONUS.csv']);
crd=[tab.lat,tab.lon];

sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';
nt=length(tnum);

%% see script readNLDAS_Hourly_siteLst
dataLst={'FORA','FORB','NOAH'};
for k=1:length(dataLst)
	dataFolder=[kPath.NLDAS_SCAN_Mat,kPath.s,'NLDAS_',dataLst{k},'_Daily',kPath.s];
	matFileLst=dir([dataFolder,'*.mat']);
	for i=1:length(matFileLst)
		matFile=[dataFolder,matFileLst(i).name];
		fieldName=matFileLst(i).name(1:end-4);
		matData=load(matFile);
		disp(fieldName)
		tic
        
        [C,indT0,indT]=intersect(tnum,matData.tnum);
        
        output=matData.data(:,indT);
        output(isnan(output))=-9999;
        dataFile=[dbFolder,kPath.s,fieldName,'.csv'];
        dlmwrite(dataFile,output,'precision',8);
        
        % stat
        statFile=[dbFolder,kPath.s,fieldName,'_stat.csv'];
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
        
		toc
	end
end
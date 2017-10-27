
% this script will write all data to csv of SMAP CONUS grid, Daily. 


global kPath
% maskFile is created by dataset/script_maskSMAP_CONUS
maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];
maskMat=load(maskFile);

%% initial Database
dirDatabase=[kPath.DBSMAP_L3,'LongTerm',kPath.s];
mkdir(dirDatabase)

crdFile=[dirDatabase,'crd.csv'];
crd=[maskMat.lat1D,maskMat.lon1D];
dlmwrite(crdFile,crd,'precision',12);

timeFile=[dirDatabase,'time.csv'];
sd=20050401;
ed=20150401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';
yrLst=year(tnum(1)):year(tnum(end));
dlmwrite(timeFile,tnum,'precision',12);

%% NLDAS - see script_NLDAS2SMAP_CONUS
dataLst={'FORA','FORB','NOAH'};
for k=1:length(dataLst)    
    dataFolderTemp=[kPath.NLDAS,'NLDAS_Daily',kPath.s,dataLst{k},kPath.s,num2str(2005),kPath.s];
	matFileLst=dir([dataFolderTemp,'*.mat']);
	for i=1:length(matFileLst)
		tic
		tnumTemp=[];
		dataTemp=[];
		fieldName=matFileLst(i).name(1:end-4);
		disp(fieldName)
		for yr=yrLst
            disp(['year ',num2str(yr)])
			dataFolder=[kPath.NLDAS,'NLDAS_Daily',kPath.s,dataLst{k},kPath.s,num2str(yr),kPath.s];
			matFile=[dataFolder,matFileLst(i).name];
			matData=load(matFile);
            dataIntp=interpGridArea(matData.lon,matData.lat,matData.data,maskMat.lon,maskMat.lat);
			dataTemp=cat(3,dataTemp,dataIntp);
			tnumTemp=[tnumTemp,matData.tnum];
		end
		grid2csv_SMAP(dataTemp,dirDatabase,tnumTemp,tnum,fieldName)
		toc
	end
end






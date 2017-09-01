
% this script will write all data to csv of SMAP CONUS grid, Daily. 


global kPath

%% initial Database
DBname='0514v12f1'
dirDatabase=[kPath.DBNLDAS,DBname,kPath.s];
maskMat=load([kPath.NLDAS,'maskNLDASv12f1.mat']);
sd=20050101;
ed=20141231;
mkdir(dirDatabase);

crdFile=[dirDatabase,'crd.csv'];
crd=[maskMat.lat1D,maskMat.lon1D];
dlmwrite(crdFile,crd,'precision',12);

timeFile=[dirDatabase,'time.csv'];
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';
yrLst=year(tnum(1)):year(tnum(end));
dlmwrite(timeFile,tnum,'precision',12);


%% NLDAS 
%dataLst={'FORA','FORB','NOAH'};
dataLst={'NOAH'};
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
			disp(yr)
			dataFolder=[kPath.NLDAS,'NLDAS_Daily',kPath.s,dataLst{k},kPath.s,num2str(yr),kPath.s];
			matFile=[dataFolder,matFileLst(i).name];
			matData=load(matFile);
			dataTemp=cat(3,dataTemp,matData.data);
			tnumTemp=[tnumTemp,matData.tnum];
		end
		grid2csv_NLDAS(dataTemp,DBname,maskMat,tnumTemp,tnum,fieldName)
		toc
	end
end






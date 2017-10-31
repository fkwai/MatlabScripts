
% this script will write all data to csv of SMAP CONUS grid, Daily. 


global kPath
% maskFile is created by dataset/script_maskSMAP_CONUS
maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];
maskMat=load(maskFile);

%% initial Database
dirDatabase=[kPath.DBSMAP_L3,'LongTerm_35yr',kPath.s];
sd=19800401;
ed=20150401;
initDBcsv( maskMat,dirDatabase,sd,ed )

%% NLDAS - see readNLDAS_Daily_script
yrLst=year(datenumMulti(sd,1)):year(datenumMulti(ed,1));
dataLst={'FORA','FORB','NOAH'};

for k=1:length(dataLst)    
    dataFolderTemp=[kPath.NLDAS,'NLDAS_Daily',kPath.s,dataLst{k},kPath.s,num2str(2005),kPath.s];
	matFileLst=dir([dataFolderTemp,'*.mat']);    
	parfor i=1:length(matFileLst)
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






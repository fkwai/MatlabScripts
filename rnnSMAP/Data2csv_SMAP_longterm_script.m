
% this script will write all data to csv of SMAP CONUS grid, Daily. 


global kPath
% maskFile is created by dataset/script_maskSMAP_CONUS
maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];
maskMat=load(maskFile);

%% initial Database
dbNameLst={'85-95','95-05','05-15'};
sdLst={19850401,19950401,20050401};
edLst={19950401,20050401,20150401};

for kk=1:length(dbNameLst)
	dirDatabase=[kPath.DBSMAP_L3,'LongTerm_',dbNameLst{kk},kPath.s];
	sd=sdLst{kk};
	ed=edLst{kk};
	initDBcsv( maskMat,dirDatabase,sd,ed )

	%% NLDAS - see readNLDAS_Daily_script
	tnum=datenumMulti(sd,1):datenumMulti(ed,1);
	yrLst=year(tnum(1)):year(tnum(end));
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
			grid2csvDB(dataTemp,tnumTemp,dirDatabase,maskMat.mask,fieldName)
			toc
		end
	end
end






% this script will write all data to csv of SMAP CONUS grid, Daily. 


global kPath
% maskFile is created by dataset/script_maskSMAP_CONUS
maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];
maskMat=load(maskFile);

%% initial Database
dirDatabase=kPath.DBSMAP_L3_CONUS;

crdFile=[dirDatabase,'crd.csv'];
crd=[maskMat.lat1D,maskMat.lon1D];
dlmwrite(crdFile,crd,'precision',12);

timeFile=[dirDatabase,'time.csv'];
sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';
dlmwrite(timeFile,tnum,'precision',12);


%% write SMAP
disp('SMAP')
tic
SMAPFile=[kPath.SMAP,'SMAP_L3.mat'];
SMAPmat=load(SMAPFile);
% shrink global to CONUS
[C,indTemp,indY]=intersect(maskMat.lat,SMAPmat.lat,'stable');
[C,indTemp,indX]=intersect(maskMat.lon,SMAPmat.lon,'stable');
data=SMAPmat.data(indY,indX,:);
tIn=SMAPmat.tnum;

grid2csvDB(data,tIn,dirDatabase,maskMat.mask,'SMAP')
grid2csvDB(data,tIn,dirDatabase,maskMat.mask,'SMAP','doAnomaly',1)

toc

%% SMAP flags - see readSMAPflag_script.m
flagTab=readtable([kPath.SMAP,'SMAP_L3_flag.csv']);
for k=1:height(flagTab)
    fieldName=flagTab.Filename{k};
	disp(fieldName)
	tic
	nBit=flagTab.Bit(k);
    flagFile=[kPath.SMAP,'SMAP_L3_flag',kPath.s,fieldName,'.mat'];
	flagMat=load(flagFile);
	% shrink global to CONUS
	[C,indTemp,indY]=intersect(maskMat.lat,flagMat.lat,'stable');
	[C,indTemp,indX]=intersect(maskMat.lon,flagMat.lon,'stable');
	data=flagMat.data(indY,indX,:);	
	if nBit==-1
		doStat=1;
		data=nanmean(data,3);
	else
		doStat=0;
		data=round(nanmean(data,3));
	end
    grid2csvDB(data,0,dirDatabase,maskMat.mask,fieldName,'doStat',doStat)

	toc
end


%% NLDAS - see script_NLDAS2SMAP_CONUS
dataLst={'MOS'};
for k=1:length(dataLst)
	dataFolder=[kPath.NLDAS,'NLDAS_gridSMAP_CONUS_Daily',kPath.s,'NLDAS_',dataLst{k},'_Daily',kPath.s];
	matFileLst=dir([dataFolder,'*.mat']);
	for i=1:length(matFileLst)
		matFile=[dataFolder,matFileLst(i).name];
		fieldName=matFileLst(i).name(1:end-4);
		matData=load(matFile);
		if strcmp(dataLst{k},'MOS') || strcmp(dataLst{k},'VIC')
			fieldName=[fieldName,'_MOS'];
		end
		disp(fieldName)
		tic
        grid2csvDB(data,tIn,dirDatabase,maskMat.mask,fieldName)
		toc
	end
end





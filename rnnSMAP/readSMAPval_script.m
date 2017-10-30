
% read in-situ database, which also called as core validation sites of
% SMAP. Database downloaded from in NSIDC (see gitbook)

global kPath

% 2015.04.01 has all SMP and SMPE in-situ data. 
% 2015.04.13 has all SMA and SMAP in-situ data. 
siteFolder=[kPath.SMAP_VAL,'NSIDC-0712.001',filesep,'2015.04.01'];

fileLst=dir([siteFolder,filesep,'*.txt']);
fileNameLst={fileLst.name};

site=[];
for k=1:length(fileNameLst)
    fileName=[siteFolder,filesep,fileNameLst{k}];
    site=[site;readSMAPval(fileName)];
end

% find corresponding SMAP cell
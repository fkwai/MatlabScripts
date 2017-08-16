function subsetSplit_All(subsetName)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.
% subset will be wrote as an individual database instead of a index file.
% And the inds in subset file is replace by -1

global kPath

%% read variable list
varFile=[kPath.DBSMAP_L3,'Variable',kPath.s,'varLst.csv'];
varConstFile=[kPath.DBSMAP_L3,'Variable',kPath.s,'varConstLst.csv'];
varLst=textread(varFile,'%s');
varConstLst=textread(varConstFile,'%s');

%% time series variable
for k=1:length(varLst)
    disp([subsetName,' ',varLst{k}])
    tic
    subsetSplit(varLst{k},subsetName)
    toc
end

%% constant variable
for k=1:length(varConstLst)
    disp([subsetName,' ',varConstLst{k}])
    tic
    subsetSplit(['const_',varConstLst{k}],subsetName)
    toc
end

%% SMAP
disp([subsetName,' SMAP'])
tic
subsetSplit('SMAP',subsetName)
toc

%% replace the subset file
subsetFile=[kPath.DBSMAP_L3,'Subset',kPath.s,subsetName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
fclose(fid);
dlmwrite(subsetFile,subsetName,'');
dlmwrite(subsetFile, -1,'-append');





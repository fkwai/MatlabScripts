function subsetSplit_All(subsetName,varargin)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.
% subset will be wrote as an individual database instead of a index file.
% And the inds in subset file is replace by -1

global kPath
if isempty(kPath)
    initPath workstation
end    

pnames={'dirRoot'};
dflts={kPath.DBSMAP_L3};
[dirRoot]=internal.stats.parseArgs(pnames, dflts, varargin{:});


%% read variable list
varFile=[dirRoot,'Variable',kPath.s,'varLst.csv'];
varConstFile=[dirRoot,'Variable',kPath.s,'varConstLst.csv'];
varLst=textread(varFile,'%s');
varConstLst=textread(varConstFile,'%s');

%% time series variable
parfor k=1:length(varLst)
    disp([subsetName,' ',varLst{k}])
    tic
    subsetSplit(varLst{k},subsetName,'dirRoot',dirRoot)
    toc
end

%% constant variable
for k=1:length(varConstLst)
    disp([subsetName,' ',varConstLst{k}])
    tic
    subsetSplit(['const_',varConstLst{k}],subsetName,'dirRoot',dirRoot)
    toc
end

%% SMAP
%{
disp([subsetName,' SMAP'])
tic
subsetSplit('SMAP',subsetName)
toc
%}

%% replace the subset file
subsetFile=[dirRoot,'Subset',kPath.s,subsetName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
fclose(fid);
dlmwrite(subsetFile,subsetName,'');
dlmwrite(subsetFile, -1,'-append');





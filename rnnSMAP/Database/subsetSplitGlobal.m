function msg=subsetSplitGlobal(subsetName,varargin)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.
% subset will be wrote as an individual database instead of a index file.
% And the inds in subset file is replace by -1

% do subset for yearly database (global database)

global kPath

pnames={'rootDB','varLst','varConstLst','yrLst'};
dflts={kPath.DBSMAP_L3_Global,'varLst','varConstLst',[]};
[rootDB,varLstName,varConstLstName,yrLst]=internal.stats.parseArgs(pnames, dflts, varargin{:});
msg=[];

%% read subset index
subsetFile=[rootDB,'Subset',filesep,subsetName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
dataName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);


%% init database
inDB=[rootDB,dataName,filesep];
outDB=[rootDB,subsetName,filesep];
% get all years if not given
if isempty(yrLst)
    dirLst=dir(inDB);
    for k=1:length(dirLst)
        if dirLst(k).isdir && ...
                ~strcmp(dirLst(k),'.') && ...
                ~strcmp(dirLst(k),'..') && ...
                ~strcmp(dirLst(k),'const')
            yrLst=[yrLst;str2num(dirLst(k).name)];
        end
    end
end

if indSub~=-1
    if ~isdir(outDB)
        mkdir(outDB)
    end
    % time series year folders
    for k=1:length(yrLst)
        outDByr=[outDB,num2str(yrLst(k)),filesep];
        inDByr=[inDB,num2str(yrLst(k)),filesep];
        if ~isdir(outDByr)
            mkdir(outDByr)
        end
        copyfile([inDByr,'time.csv'],[outDByr,'time.csv']);
    end
    % constant folder
    outDBconst=[outDB,'const',filesep];
    if ~isdir(outDBconst)
        mkdir(outDBconst)
    end
    % crd file
    inCrdFile=[inDB,'crd.csv'];
    outCrdFile=[outDB,'crd.csv'];
    inCrd=csvread(inCrdFile);
    outCrd=inCrd(indSub,:);
    dlmwrite(outCrdFile,outCrd,'precision',8);
else
    inCrd=csvread([inDB,'crd.csv']);
    outCrd=csvread([outDB,'crd.csv']);
    [inInd,outInd] = intersectCrd( inCrd,outCrd);
    if length(inInd)~=size(outInd,1)
        error('check here')
    end
    indSub=outInd;
end

%% read variable list
if iscell(varLstName)
    varLst=varLstName;
elseif ischar(varLstName)
    varFile=[rootDB,'Variable',kPath.s,varLstName,'.csv'];
    varLst=textread(varFile,'%s');
end

if iscell(varConstLstName)
    varConstLst=varConstLstName;
elseif ischar(varConstLstName)
    varConstFile=[rootDB,'Variable',kPath.s,varConstLstName,'.csv'];
    varConstLst=textread(varConstFile,'%s');
end

%% time series variable
for iY=1:length(yrLst)
    outDByr=[outDB,num2str(yrLst(iY)),filesep];
    inDByr=[inDB,num2str(yrLst(iY)),filesep];
    parfor k=1:length(varLst)
        tic
        errMsg=subsetSplit_var(varLst{k},inDByr,outDByr,indSub);
        msg=[msg;errMsg];
        disp([subsetName,'  ',varLst{k},'  ',num2str(yrLst(iY)),'  ',num2str(toc)])
    end
end

%% constant variable
for k=1:length(varConstLst)
    inDBconst=[inDB,'const',filesep];
    outDBconst=[outDB,'const',filesep];
    tic
    errMsg=subsetSplit_var([varConstLst{k}],inDBconst,outDBconst,indSub);
    msg=[msg;errMsg];
    disp([subsetName,'  ',varConstLst{k},'  ',num2str(toc)])
end

%% replace the subset file
dlmwrite(subsetFile,subsetName,'');
dlmwrite(subsetFile, -1,'-append');

end

function errMsg=subsetSplit_var(varName,rootFolder,saveFolder,indSub)

% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.

% write a subset database for given subset index and variable name

dataFileRoot=[rootFolder,varName,'.csv'];
if exist(dataFileRoot,'file')
    errMsg=[];
    %% pick data by indSub
    data=csvread(dataFileRoot);
    dataSub=data(indSub,:);
    
    %% save data
    saveFile=[saveFolder,varName,'.csv'];
    dlmwrite(saveFile, dataSub,'precision',8);
else
    errMsg=['can not find ',dataFileRoot];
end

end




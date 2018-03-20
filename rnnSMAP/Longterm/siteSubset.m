function siteSubset(crdSiteLst,dataNameLst,outName,varargin)
% will do following:
% 1. find subset index of sites
% 2. split subset for given DBs (8595, 9505, ...)
% 3. combine those splited subsets

global kPath
varinTab={'rootDB',kPath.DBSMAP_L3;...
    'suffix','site';... % suffix for all subsets
    'varName','varLst_Noah';...
    'varConstName','varConstLst_Noah';...
    };
[rootDB,suffix,varName,varConstName]=...
    internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

refName=dataNameLst{end};
dataNameLst_site=cell(size(dataNameLst));
for k=1:length(dataNameLst_site)
    dataNameLst_site{k}=[dataNameLst{k},suffix];
end


%% find subset index
crd=csvread([rootDB,refName,filesep,'crd.csv']);
indLst=[];
for k=1:size(crdSiteLst,1)
    crdSite=crdSiteLst(k,:);
    [C,ind]=min(sum(abs(crd-crdSite),2));
    disp([num2str(k),': ',num2str(C,3)])
    indLst=[indLst;ind];
end
indSubset=unique(indLst);

%% do subset of those pixels and run test
for k=1:length(dataNameLst)
    rootName=dataNameLst{k};
    subsetFile=[rootDB,'Subset',filesep,rootName,suffix,'.csv'];
    dlmwrite(subsetFile,rootName,'');
    dlmwrite(subsetFile,indSubset,'-append');
end

for k=1:length(dataNameLst)
    rootName=dataNameLst{k};
    subsetName=[rootName,suffix];
    subsetSplit(subsetName,'dirRoot',rootDB,'varLst',varName,'varConstLst',varConstName);    
end

%% combine sites
combineDB_time( dataNameLst_site,outName,'rootDB',rootDB,'varName',varName,'varConstName',varConstName);

end


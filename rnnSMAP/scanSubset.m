function scanSubset(rootDB)
% this function will scan database root folder and write subset files for
% those databases do not have one (due to mis-action before)

global kPath
dirs = dir(rootDB);
dirs(1:2) = [];
dirs = dirs([dirs.isdir]);
subsetNameLst={dirs.name}';
subsetFolder=[rootDB,kPath.s,'Subset',kPath.s];

if ~exist(subsetFolder,'dir')
    mkdir(subsetFolder);
end

for k=1:length(subsetNameLst)
    subsetName=subsetNameLst{k};
    subsetFile=[subsetFolder,subsetName,'.csv'];
    if ~exist(subsetFile,'file')
        
    end
end

end


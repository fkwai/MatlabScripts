function subsetSMAP_indSub(indSub,rootName,subsetName,varargin )
%directly write subset based on indSub

global kPath
if isempty(varargin)
    rootDB=kPath.DBSMAP_L3;
else
    rootDB=varargin{1};
end

subsetFolder=[rootDB,'Subset',filesep];

%% save index file. Name by default
subsetFile=[subsetFolder,subsetName,'.csv'];
dlmwrite(subsetFile,rootName,'');
dlmwrite(subsetFile, indSub,'-append');

end


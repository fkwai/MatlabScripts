function subsetSMAP_indSub( rootName,indSub,subsetName )
%directly write subset based on indSub

global kPath
if isempty(kPath)
    initPath workstation
end    
subsetFolder=[kPath.DBSMAP_L3,'Subset',kPath.s];

%% save index file. Name by default
subsetFile=[subsetFolder,subsetName,'.csv'];
dlmwrite(subsetFile,rootName,'');
dlmwrite(subsetFile, indSub,'-append');

end


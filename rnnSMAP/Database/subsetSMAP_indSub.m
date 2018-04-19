function subsetSMAP_indSub(indSub,rootDB,subsetRoot,subsetName )
%directly write subset based on indSub

subsetFolder=[rootDB,filesep,'Subset',filesep];
subsetFile=[subsetFolder,subsetName,'.csv'];
dlmwrite(subsetFile,subsetRoot,'');
dlmwrite(subsetFile, indSub,'-append');

end


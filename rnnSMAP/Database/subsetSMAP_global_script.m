
%  a script summarized all steps to create existing subsets

%% interval - write Database
global kPath
maskFile=[kPath.SMAP,'maskSMAP_L3.mat'];
rootDB=[kPath.DBSMAP_L3_Global];
dbName='Global';
 vecV=[8,4];
 vecF=[1,1];
for k=1:length(vecV)
    interval=vecV(k);
    offset=vecF(k);
    subsetSMAP_interval(interval,offset,'mask',maskFile,'rootDB',rootDB,'subsetRoot',dbName);
    subsetName=[dbName,'v',num2str(interval),'f',num2str(offset)];
    %subsetSplitGlobal(subsetName)
    subsetSplitGlobal(subsetName,'varLst',{'TRMM'},'varConstLst',{})
end


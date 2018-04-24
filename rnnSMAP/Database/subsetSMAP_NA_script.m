
%  a script summarized all steps to create existing subsets

%% interval - write Database
global kPath
rootDB=[kPath.DBSMAP_L3_NA];
dbName='CONUS';
 vecV=[4];
 vecF=[1];
for k=1:length(vecV)
    interval=vecV(k);
    offset=vecF(k);
    subsetSMAP_interval(interval,offset,'NA_L3');
    subsetName=[dbName,'v',num2str(interval),'f',num2str(offset)];   
    msg=subsetSplitGlobal(subsetName,'rootDB',rootDB);
end


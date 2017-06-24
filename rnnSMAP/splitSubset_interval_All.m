function splitSubset_interval_All(interval,offset)
% do split of subset of gridSMAP, L3, Daily, CONUS

global kPath
varFile=[kPath.DBSMAP_L3_CONUS,'varLst.csv'];
varConstFile=[kPath.DBSMAP_L3_CONUS,'varLst.csv'];
varLst=textread(varFile,'%s');
varConstLst=textread(varConstFile,'%s');

dataName=['CONUSs',num2str(interval),'f',num2str(offset)];
dataFolder=[kPath.DBSMAP_L3,dataName,kPath.s];
if ~exist(dataFolder,'dir')
	mkdir(dataFolder)
end
varFileNew=[dataFolder,'varLst.csv'];
varConstFileNew=[dataFolder,'varConstLst.csv'];
copyfile(varFile,varFileNew);
copyfile(varConstFile,varConstFileNew);

for k=1:length(varLst)
    varLst{k}
    tic
    splitSubset_interval(varLst{k},dataName,interval,offset)
    toc
end
for k=1:length(varConstLst)
    varConstLst{k}
    tic
    splitSubset_interval(varConstLst{k},dataName,interval,offset)
    toc
end





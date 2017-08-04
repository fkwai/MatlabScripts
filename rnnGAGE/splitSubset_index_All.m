function splitSubset_index_All(indSub)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP. 

global kPath
varFile=[kPath.DBSCAN,'CONUS',kPath.s,'varLst.csv'];
varConstFile=[kPath.DBSCAN,'CONUS',kPath.s,'varConstLst.csv'];
varLst=textread(varFile,'%s');
varConstLst=textread(varConstFile,'%s');

dataName=['site',num2str(indSub)];
dataFolder=[kPath.DBSMAP_L3,dataName,kPath.s];
if ~exist(dataFolder,'dir')
	mkdir(dataFolder)
end
varFileNew=[dataFolder,'varLst.csv'];
varConstFileNew=[dataFolder,'varConstLst.csv'];
copyfile(varFile,varFileNew);
copyfile(varConstFile,varConstFileNew);

% time series variable
for k=1:length(varLst)
    disp([num2str(indSub),varLst{k}])
    tic
    splitSubset_index(varLst{k},dataName,indSub);
    toc
end

% constant variable
for k=1:length(varConstLst)
    disp([num2str(interval),' ',num2str(offset),' ',varConstLst{k}])
    tic
    splitSubset_index(['const_',varConstLst{k}],dataName,indSub);
    toc
end
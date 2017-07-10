function splitSubset(dataName,method, interval,offset,varargin)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.

% A function to call all methods.

global kPath
varFile=[kPath.DBSMAP_L3_CONUS,'varLst.csv'];
varConstFile=[kPath.DBSMAP_L3_CONUS,'varConstLst.csv'];
varLst=textread(varFile,'%s');
varConstLst=textread(varConstFile,'%s');

%dataName=['CONUSs',num2str(interval),'f',num2str(offset)];
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
    disp([dataName,' ',varLst{k}])
    tic
    switch method
        case 'interval'
            splitSubset_interval(varLst{k},dataName,interval,offset);
        case 'shape'
            shapefile=varargin{1};
            splitSubset_shapefile(varLst{k},dataName,...
                shapefile,'interval',interval,'offset',offset )
        otherwise
            error('method not found')
    end
    toc
end

% constant variable
for k=1:length(varConstLst)
    disp([dataName,' ',varConstLst{k}])
    tic
    switch method
        case 'interval'
            splitSubset_interval(['const_',varConstLst{k}],dataName,interval,offset);
        case 'shape'
            shapefile=varargin{1};
            splitSubset_shapefile(['const_',varConstLst{k}],dataName,...
                shapefile,'interval',interval,'offset',offset )
        otherwise
            error('method not found')
    end
    toc
end

% SMAP
disp([dataName,' SMAP'])
tic
switch method
    case 'interval'
        splitSubset_interval('SMAP',dataName,interval,offset)
        splitSubset_interval('SMAP_Anomaly',dataName,interval,offset)
    case 'shape'
        shapefile=varargin{1};
        splitSubset_shapefile('SMAP',dataName,...
            shapefile,'interval',interval,'offset',offset )
        splitSubset_shapefile('SMAP_Anomaly',dataName,...
            shapefile,'interval',interval,'offset',offset )
    otherwise
        error('method not found')
end
toc

%% Sample Scripts - splitsubset shapefile
% sLstACD={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% sLstBCD={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% sLstA={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';};
% sLstB={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';};
% splitSubset('regionACDs2','shape',2,1,sLstACD)
% splitSubset('regionBCDs2','shape',2,1,sLstBCD)
% splitSubset('regionAs2','shape',2,1,sLstA)
% splitSubset('regionBs2','shape',2,1,sLstB)
% 
% 



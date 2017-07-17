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

varFileLst=dir([kPath.DBSMAP_L3_CONUS,'var*']);
for k=1:length(varFileLst)
    varFileOld=[kPath.DBSMAP_L3_CONUS,varFileLst(k).name];
    varFileNew=[dataFolder,varFileLst(k).name];
    copyfile(varFileOld,varFileNew);
end

%% time series variable
for k=1:length(varLst)
    disp([dataName,' ',varLst{k}])
    tic
    switch method
        case 'interval'
            indOut=splitSubset_interval(varLst{k},dataName,interval,offset);
        case 'shape'
            shapefile=varargin{1};
            if k==1
                indOut=splitSubset_shapefile(varLst{k},dataName,shapefile,...
                    'interval',interval,'offset',offset);
            else
                splitSubset_shapefile(varLst{k},dataName,shapefile,...
                    'indOut',indOut,'interval',interval,'offset',offset);
            end
        otherwise
            error('method not found')
    end
    toc
end

%% constant variable
for k=1:length(varConstLst)
    disp([dataName,' ',varConstLst{k}])
    tic
    switch method
        case 'interval'
            indOut=splitSubset_interval(['const_',varConstLst{k}],dataName,interval,offset);
        case 'shape'
            shapefile=varargin{1};
            splitSubset_shapefile(['const_',varConstLst{k}],dataName,shapefile,...
                'indOut',indOut,'interval',interval,'offset',offset);
            
        otherwise
            error('method not found')
    end
    toc
end

%% SMAP
disp([dataName,' SMAP'])
tic
switch method
    case 'interval'
        splitSubset_interval('SMAP',dataName,interval,offset)
        splitSubset_interval('SMAP_Anomaly',dataName,interval,offset)
    case 'shape'
        shapefile=varargin{1};
        splitSubset_shapefile('SMAP',dataName,shapefile,...
            'indOut',indOut,'interval',interval,'offset',offset );
        splitSubset_shapefile('SMAP_Anomaly',dataName,shapefile,...
            'indOut',indOut,'interval',interval,'offset',offset );
    otherwise
        error('method not found')
end
toc





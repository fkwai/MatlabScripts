function varWarning= statDBcsv_Year(rootDB,dataName,yrLst,varargin)
% calculate stat of database and save in rootDB/Statistics.

% for example, following code will calculate stat based on 2015 and 2016
% dataset

% global kPath
% rootDB=kPath.DBSMAP_L3_Global;
% dataName='Global';
% yrLst=2015:2016;


pnames={'varLst','varConstLst'};
dflts={[],[]};
[varLst,varConstLst]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});


varWarning={};

%% get time series variable list
if isempty(varLst)
    varLstAll=cell(length(yrLst),1);
    for k=1:length(yrLst)
        varLstTemp=[];
        dirDB=[rootDB,dataName,filesep,num2str(yrLst(k)),filesep];
        fileLst=dir([dirDB,'*.csv']);
        for kk=1:length(fileLst)
            if ~strcmp(fileLst(kk).name,'time.csv') && ~strcmp(fileLst(kk).name,'crd.csv')
                varLstTemp=[varLstTemp;{fileLst(kk).name(1:end-4)}];
            end
        end
        varLstAll{k}=varLstTemp;
    end
    for k=2:length(yrLst)
        if ~isequal(varLstAll{1},varLstAll{k})
            error('different fields between years')
        end
    end
    varLst=varLstAll{1};
end

%% calculate stat for each time series variables
for k=1:length(varLst)
    data=[];
    var=varLst{k};
    statFile=[rootDB,'Statistics',filesep,var,'_stat.csv'];
    disp(['calculating stat for ',var]);
    tic
    for iY=1:length(yrLst)
        dirDB=[rootDB,dataName,filesep,num2str(yrLst(iY)),filesep];
        temp=csvread([dirDB,var,'.csv']);
        data=cat(2,data,temp);
    end
    % calculate
    vecData=data(:);
    vecData(vecData==-9999)=[];
    perc=10;
    lb=prctile(vecData,perc);
    ub=prctile(vecData,100-perc);
    data80=vecData(vecData>=lb &vecData<=ub);
    m=mean(data80);
    sigma=std(data80);
    stat=[lb;ub;m;sigma];
    dlmwrite(statFile, stat,'precision',8);
    if sigma==0
        varWarning=[varWarning;var];
    end
    toc
end

%% calculate stat for const
dirDBconst=[rootDB,dataName,filesep,'const',filesep];
if isempty(varConstLst)    
    fileLst=dir([dirDBconst,'*.csv']);
    varConstLst=[];
    for kk=1:length(fileLst)
        if ~strcmp(fileLst(kk).name,'crd.csv')
            varConstLst=[varConstLst;{fileLst(kk).name(1:end-4)}];
        end
    end
end

for k=1:length(varConstLst)
    var=varConstLst{k};
    statFile=[rootDB,'Statistics',filesep,'const_',var,'_stat.csv'];
    data=csvread([dirDBconst,var,'.csv']);    
    data(data==-9999)=[];    
    if isequal(unique(data),[0;1])
        stat=[0,1,0,1];
    else
        perc=10;
        lb=prctile(data,perc);
        ub=prctile(data,100-perc);
        data80=data(data>=lb &data<=ub);
        m=mean(data80);
        sigma=std(data80);
        stat=[lb;ub;m;sigma];
    end
    dlmwrite(statFile, stat,'precision',8);
    if stat(4)==0
        varWarning=[varWarning;var];
    end
end




end


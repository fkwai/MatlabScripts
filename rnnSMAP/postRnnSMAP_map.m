function postRnnSMAP_map(outName,dataName,varargin)
% First test for trained rnn model. 
% plot nash/rmse map for given testset and click map to plot timeseries
% comparison between GLDAS, SMAP and RNN prediction. 

% example:
%{
outName='CONUSv2f1_Noah';
dataName='CONUSv2f1';
postRnnSMAP_map(outName,dataName)
%}

global kPath

pnames={'rootOut','rootDB','mapTime','tsTime','epoch','stat','colorRange'};
dflts={kPath.OutSMAP_L3,kPath.DBSMAP_L3,2,[1,2],0,'rmse',[]};
[rootOut,rootDB,mapTime,tsTime,epoch,stat,colorRange]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% predefine
fileCrd=[rootDB,dataName,filesep,'crd.csv'];
crd=csvread(fileCrd);
fileDate=[rootDB,dataName,filesep,'time.csv'];
tnum=csvread(fileDate);

opt=readRnnOpt(outName,rootOut);
if epoch==0
    epoch=opt.nEpoch;
end


%% read Map data and calculate stat
out=postRnnSMAP_load(outName,dataName,mapTime,epoch,...
    'rootOut',rootOut,'rootDB',rootDB);
statLSTM=statCal(out.yLSTM,out.ySMAP);
[gridStatLSTM,xx,yy] = data2grid(statLSTM.(stat),crd(:,2),crd(:,1));

%% read timeseries data and transfer to grid
for iT=1:length(tsTime)
    outTS{iT}=postRnnSMAP_load(outName,dataName,tsTime(iT),epoch,...
    'rootOut',rootOut,'rootDB',rootDB);
end
tIndLst={1:366; 367:732; 1:732};
legLst={'ySMAP','yGLDAS','yLSTM'}; % hard coded. Add more if needed. will be plotted in order.
symLst={'or','-k','-b'};


for k=1:length(legLst)
    tsData=[];
    for iT=1:length(tsTime)
        tsData=[tsData;outTS{iT}.(legLst{k})];
    end
    [gridTemp,xx,yy] = data2grid3d(tsData',crd(:,2),crd(:,1));
    tsStr(k).grid=gridTemp;
    tsStr(k).t=tnum;
    tsStr(k).symb=symLst{k};
    tsStr(k).legendStr=legLst{k};
end

yIn=[length(yy):-1:1]';
xIn=1:length(xx);

showGrid( gridStatLSTM,yIn,xIn,1,'colorRange',colorRange,'tsStr',tsStr,'yRange',[0,0.5])
end


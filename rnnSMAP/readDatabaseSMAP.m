function [xOut,yOut,xStat,yStat]=readDatabaseSMAP(trainFolder,trainName,varargin)

%% example
% trainFolder='Y:\Kuai\rnnSMAP\output\NA_division\';
% trainName='div1';
% mode = 0 -> raw data; 1 -> normalization; 
pnames={'mode','xField','xField_const','yField'};
dflts={1,0,0,0};
[mode,xField,xField_const,yField]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% Default setting
dataFolder='Y:\Kuai\rnnSMAP\Database\';
if xField==0
    xField={'soilM','Evap','Rainf','Tair','Wind','PSurf','Canopint','Snowf'};
end
if xField_const==0
    xField_const={'DEM','Slope','Sand','Silt','Clay','LULC','NDVI'};
end
if yField==0
    yField='SMPq';
end
nt=4160;

%% load X data
trainFile=[trainFolder,trainName,'.csv'];
trainInd=csvread(trainFile);
xData=zeros(nt,length(trainInd),length(xField)+length(xField_const))*nan;
xStat=zeros(4,length(xField)+length(xField_const))*nan;

for kk=1:length(xField)
    k=kk;
    xfolder=[dataFolder,'\tDB_',xField{kk},'\'];
    x=zeros(nt,length(trainInd));
    for i=1:length(trainInd)
        xfile=[xfolder,'\data\',sprintf('%06d',trainInd(i)),'.csv'];
        x(:,i)=csvread(xfile);
    end
    xData(:,:,k)=x;
    temp=csvread([xfolder,'stat.csv']);
    xStat(:,k)=temp;
end
for kk=1:length(xField_const)
    k=kk+length(xField);
    xfolder=[dataFolder,'\tDBconst_',xField_const{kk},'\'];
    nt=4160;
    xfile=[xfolder,'\data.csv'];
    xRaw=csvread(xfile);
    x=xRaw(trainInd);
    xData(:,:,k)=repmat(x',[nt,1]);
    temp=csvread([xfolder,'stat.csv']);
    xStat(:,k)=temp;
end


%% load Y data
trainFile=[trainFolder,trainName,'.csv'];
trainInd=csvread(trainFile);
yData=zeros(nt,length(trainInd))*nan;
yStat=zeros(4,length(xField)+length(xField_const))*nan;

yfolder=[dataFolder,'\tDB_',yField,'\'];
for i=1:length(trainInd)
    yfile=[yfolder,'data\',sprintf('%06d',trainInd(i)),'.csv'];
    yData(:,i)=csvread(yfile);
end
yStat=csvread([yfolder,'stat.csv']);

%% normalize data
xData(xData==-9999)=nan;
yData(yData==-9999)=nan;
if mode==0
    xOut=xData;
    yOut=yData;
elseif mode==1
    xDataNorm=zeros(nt,length(trainInd),length(xField)+length(xField_const))*nan;
    for k=1:length(xField)+length(xField_const)
        xtemp=xData(:,:,k);
        xDataNorm(:,:,k)=(xtemp-xStat(1,k))/(xStat(2,k))*2-1;
    end
    yDataNorm=(yData-yStat(1))/(yStat(2))*2-1;
    xOut=xDataNorm;
    yOut=yDataNorm;
end
end
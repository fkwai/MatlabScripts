function [xOut,yOut,xStat,yStat] = readDatabaseSMAP_All(dataName,varargin)
%read new SMAP database where each variable is saved in one file. 

pnames={'varLstName','varConstLstName'};
dflts={'varLst','varConstLst'};
[varLstName,varConstLstName]=internal.stats.parseArgs(pnames, dflts, varargin{:});

global kPath
dataFolder=kPath.DBSMAP_L3;

%% read t and crd
dirData=[dataFolder,dataName,kPath.s];
fileCrd=[dirData,'crd.csv'];
fileDate=[dirData,'time.csv'];
varFile=[dirData,varLstName,'.csv'];
varConstFile=[dirData,varConstLstName,'.csv'];
crd=csvread(fileCrd);
t=csvread(fileDate);
lat=crd(:,1);
lon=crd(:,2);

%% read varLst.csv and varConstLst.csv to xField and xField_const
yField='SMAP';
fid=fopen(varFile);
C=textscan(fid,'%s');
xField=C{1};
fclose(fid);
fid=fopen(varConstFile);
C=textscan(fid,'%s');
xField_const=C{1};
fclose(fid);
nx=length(xField)+length(xField_const);


%% read Y
yFile=[dataFolder,dataName,kPath.s,yField,'.csv'];
yStatFile=[dataFolder,dataName,kPath.s,yField,'_stat.csv'];
yData=csvread(yFile);
yStatData=csvread(yStatFile);
yData(yData==-9999)=nan;
%[grid,xx,yy] = data2grid3d( yData,lon,lat);    % testify
yOut=yData';
yStat=yStatData;
[nt,ngrid]=size(yOut);

%% read X
xOut=zeros([nt,ngrid,nx]);
xStat=zeros([4,nx]);

for kk=1:length(xField)
    k=kk;
    xFile=[dataFolder,dataName,kPath.s,xField{kk},'.csv'];
    xStatFile=[dataFolder,dataName,kPath.s,xField{kk},'_stat.csv'];
    xData=csvread(xFile);
	%xData(xData==-9999)=0;
    xStatData=csvread(xStatFile);
	%xDataNorm=(xData-xStatData(3))./xStatData(4);
    xOut(:,:,k)=xData';
    xStat(:,k)=xStatData;
end
for kk=1:length(xField_const)
    k=kk+length(xField);
    xFile=[dataFolder,dataName,kPath.s,'const_',xField_const{kk},'.csv'];
    xStatFile=[dataFolder,dataName,kPath.s,'const_',xField_const{kk},'_stat.csv'];
    xData=csvread(xFile);
	%xData(xData==-9999)=0;
    xStatData=csvread(xStatFile);
	%xDataNorm=(xData-xStatData(3))./xStatData(4);
    xOut(:,:,k)=repmat(xData',[nt,1]);
    xStat(:,k)=xStatData;
    %[grid,xx,yy] = data2grid( xData,lon,lat);  
end

end


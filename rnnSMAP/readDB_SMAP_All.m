function [xOut,yOut,xStatOut,yStatOut] = readDB_SMAP_All(dataName,varargin)
%read new SMAP database where each variable is saved in one file. 

pnames={'var','varC'};
dflts={'varLst','varConstLst'};
[varLstName,varConstLstName]=internal.stats.parseArgs(pnames,dflts,varargin{:});

global kPath

%% read dataset index
subsetFile=[kPath.DBSMAP_L3,'Subset',kPath.s,dataName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);

%% read t and crd
dirData=[kPath.DBSMAP_L3,rootName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
if isequal(indSub,[-1])
    indSub=[1:length(crd)]';
end


%% read varLst.csv and varConstLst.csv to xField and xField_const
varFile=[kPath.DBSMAP_L3,'Variable',kPath.s,varLstName,'.csv'];
varConstFile=[kPath.DBSMAP_L3,'Variable',kPath.s,varConstLstName,'.csv'];
fid=fopen(varFile);
C=textscan(fid,'%s');
xField=C{1};
fclose(fid);
fid=fopen(varConstFile);
C=textscan(fid,'%s');
xField_const=C{1};
fclose(fid);
nx=length(xField)+length(xField_const);
yField='SMAP';

%% read Y
[yData,yStat,yDataNorm]=readDatabaseSMAP(rootName,yField);
yOut=yData(:,indSub);
[nt,ngrid]=size(yOut);
yStatOut=yStat;

%% read X
xOut=zeros([nt,ngrid,nx]);
xStatOut=zeros([4,nx]);

for kk=1:length(xField)
    k=kk;    
    [xData,xStat,xDataNorm]=readDatabaseSMAP(rootName,xField{kk});
    xDataNorm(isnan(xDataNorm))=0;
    xOut(:,:,k)=xDataNorm(:,indSub);
    xStatOut(:,k)=xStat;
end
for kk=1:length(xField_const)
    k=kk+length(xField);    
    [xData,xStat,xDataNorm]=readDatabaseSMAP(rootName,['const_',xField_const{kk}]);
    xDataNorm(isnan(xDataNorm))=0;
    xOut(:,:,k)=repmat(xDataNorm(:,indSub),[nt,1]);
    xStatOut(:,k)=xStat;    
end

end


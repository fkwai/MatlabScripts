function grid2csvDB(data,tIn,dirDB,mask,varName,varargin)
% convert grid to csv file in database that torch can learn from
% time.csv and crd.csv are supposed to already existed in database. 

% input:
% data - 3D grid [lat,lon,t], and is supposed to have same grid and time step as hard coded mask
% tIn - tnum of data. if tIn=0 then it is a const field
% tOut - output tnum
% dirDB - Example: kPath.DBSMAP_L3_CONUS
% mask - Example: '\SMAP\maskSMAP_CONUS.mat,mask'
% varName - output name
% varargin
% doAnomaly - if do anomaly
% doStat - if ==1, it is a zero/one flag

% output: write var.csv and var_stat.csv

% example

pnames={'doAnomaly','doStat'};
dflts={0,1};
[doAnomaly,doStat]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

tIn=VectorDim(tIn,1);

crdFile=[dirDB,filesep,'crd.csv'];
if exist(crdFile,'file')
    crdOut=csvread(crdFile);
else
    crdFile=[dirDB,filesep,'..',filesep,'crd.csv'];
    crdOut=csvread(crdFile);
end

%% transfer to 2D mat 
[ny,nx,nt]=size(data);
matDataAll=reshape(data,[ny*nx,nt]);

%% find spatial index
indMask=find(mask==1);
if~isequal( length(indMask),size(crdOut,1))
    error('mask index is wrong to current database');
end
if ~isequal(size(mask),[ny,nx])
	error('grid size is different')
end

if ~isequal(length(tIn),nt)
	error('time length is different')
end

%% find temporal index
if tIn==0 % const field
    indTimeIn=1;
    %varName=['const_',varName];
else
    timeFile=[dirDB,filesep,'time.csv'];
    tOut=csvread(timeFile);
    tOut=VectorDim(tOut,1);
    [C,indTimeIn,indTimeOut]=intersect(tIn,tOut);
    if length(indTimeOut)~= length(tOut)
        error('time is not covered')
    end
end
output=matDataAll(indMask,indTimeIn);

%% do anomaly
if doAnomaly==0
    dataFile=[dirDB,varName,'.csv'];
else
    meanOutput=nanmean(output,2);
    output=output-repmat(meanOutput,[1,length(tOut)]);
    dataFile=[dirDB,varName,'_Anomaly.csv'];
end    
output(isnan(output))=-9999;
dlmwrite(dataFile,output,'precision',8);


%% compute stat of SMAP
% do not want to write stat in this function. Calculate stat for all data
% in a seperate function
%{
if doStat==1
	vecOutput=output(:);
	vecOutput(vecOutput==-9999)=[];
	perc=10;
	lb=prctile(vecOutput,perc);
	ub=prctile(vecOutput,100-perc);
	data80=vecOutput(vecOutput>=lb &vecOutput<=ub);
	m=mean(data80);
	sigma=std(data80);
	stat=[lb;ub;m;sigma];
else
	stat=[-1;1;0;1];
end
if doAnomaly==0
    statFile=[dirDB,varName,'_stat.csv'];
else
    statFile=[dirDB,varName,'_Anomaly_stat.csv'];
end
dlmwrite(statFile, stat,'precision',8);
%}

end


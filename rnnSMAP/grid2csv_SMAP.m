function grid2csv_SMAP(data,tIn,tOut,varName,varargin)
% convert grid to csv file that torch can learn from
% write directory are hard coded as kPath.DBSMAP_L3_CONUS
% mask are hard coded to kPath.maskSMAP_CONUS 
% time.csv and crd.csv are supposed to already existed in database

% data - 3D grid [lat,lon,t], and is supposed to have same grid and time step as hard coded mask
% tIn - tnum of data
% tOut - output tnum
% mask - Example: '\SMAP\maskSMAP_CONUS.mat,mask'
% varName - output name
% varargin{1} - if do anomaly
% varargin{2} - if ==1, it is a zero/one flag

doAnomaly=0;
doStat=0;
if ~isempty(varargin)
    doAnomaly=varargin{1};
	if length(varargin)>1
		doStat=varargin{2};
	end
end


global kPath
load(kPath.maskSMAP_CONUS,'mask')
dirDatabase=kPath.DBSMAP_L3_CONUS;
tIn=VectorDim(tIn,1);
tOut=VectorDim(tOut,1);

%% transfer to 2D mat 
[ny,nx,nt]=size(data);
matDataAll=reshape(data,[ny*nx,nt]);

%% find spatial index
indMask=find(mask==1);
if ~isequal(size(mask),[ny,nx])
	error('grid are different')
end

%% find temporal index
[C,indTimeIn,indTimeOut]=intersect(tIn,tOut);
if length(indTimeOut)~= length(tOut)
	error('time is not covered')
end

output=matDataAll(indMask,indTimeIn);

%% do anomaly
if doAnomaly==0
    dataFile=[dirDatabase,varName,'.csv'];
else
    meanOutput=nanmean(output,2);
    output=output-repmat(meanOutput,[1,length(tOut)]);
    dataFile=[dirDatabase,varName,'_Anomaly.csv'];
end    
output(isnan(output))=-9999;
dlmwrite(dataFile,output,'precision',8);


%% compute stat of SMAP
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
	stat=[0,1,0.5,0.5];
end
if doAnomaly==0
    statFile=[dirDatabase,varName,'_stat.csv'];
else
    statFile=[dirDatabase,varName,'_Anomaly_stat.csv'];
end
dlmwrite(statFile, stat,'precision',8);

%% check tnum
timeFile=[dirDatabase,'time.csv'];
tData=csvread(timeFile);
if ~isequal(tData,tOut)
	error('time are different with existed time file')
end

end


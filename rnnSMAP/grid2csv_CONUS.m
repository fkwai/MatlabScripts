function grid2csv_CONUS( fileName,varName ,varargin)
% convert raw matfile form NLDAS (interpolated) and SMAP to csv file that
% contains all data in CONUS

% input file (fileName) are supposed to have exact same grid as SMAP. 

doAnomaly=0;
if ~isempty(varargin)
    doAnomaly=varargin{1};
end

global kPath
dirDatabase='/mnt/sdb1/rnnSMAP/database/CONUS/';

maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];

maskMat=load(maskFile);
mask=maskMat.mask;
lat=maskMat.lat;
lon=maskMat.lon;

ind=find(mask==1);

sd=20150401;
ed=20160901;
tnum=[datenumMulti(sd,1):datenumMulti(ed,1)]';

%% start
mat=load([dirMat,fileName,'.mat']);
data=mat.data;
[ny,nx,nt]=size(data);
matData=reshape(data,[ny*nx,nt]);
matDataCONUS=matData(ind,:);

% convert to daily
output=zeros(length(ind),length(tnum));
for k=1:length(tnum)
    td=tnum(k);
    tInd=ceil(mat.tnum)==td;
    output(:,k)=nanmean(matDataCONUS(:,tInd),2);
end


if doAnomaly==0
    dataFile=[dirDatabase,varName,'.csv'];
else
    meanOutput=nanmean(output,2);
    output=output-repmat(meanOutput,[1,length(tnum)]);
    dataFile=[dirDatabase,varName,'_Anomaly.csv'];
end    
output(isnan(output))=-9999;

dlmwrite(dataFile,output','precision',8);

%% compute stat of SMAP
vecOutput=output(:);
vecOutput(vecOutput==-9999)=[];

perc=10;
lb=prctile(vecOutput,perc);
ub=prctile(vecOutput,100-perc);
data80=vecOutput(vecOutput>=lb &vecOutput<=ub);
m=mean(data80);
sigma=std(data80);
stat=[lb;ub;m;sigma];
if doAnomaly==0
    statFile=[dirDatabase,varName,'_stat.csv'];
else
    statFile=[dirDatabase,varName,'_Anomaly_stat.csv'];
end
dlmwrite(statFile, stat,'precision',8);

end


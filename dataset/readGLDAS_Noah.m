function [data,tnum] = readGLDAS_Noah(t,var,varargin)
% read GLDAS NOAH (v2.1, 0.25 deg)
% see readGLDAS_Noah_script

% t - date
% var - variable name. Can be found by ncinfo. Can not be
% lat/lon/time/time_bound. Hardcode to be 600*1440

% can not read all fields at once for parfor

pnames={'doDaily'};
dflts={1};
[doDaily]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

GLDASdir='/mnt/sdb1/Database/GLDAS/';

dn=datenumMulti(t,1);
Y=year(dn);
d1=datenumMulti(Y*10000+101,1);
D=dn-d1+1;

folder=[GLDASdir,filesep,'GLDAS_NOAH025_3H.2.1',filesep,num2str(Y),filesep,sprintf('%3.3d',D),filesep];
files = dir([folder,'*.nc4']);
nfiles=length(files);


%% read data
dataH=zeros(600,1440,nfiles)*nan;
tnumH=zeros(nfiles,1);
for i=1:nfiles
    fileName=[folder,files(i).name];
    C=strsplit(files(i).name,'.');
    tstr=[C{2}(2:end),'-',C{3}];
    t=datenum(tstr,'yyyymmdd-HHMM');
    temp=ncread(fileName,var);
    dataH(:,:,i)=flipud(temp');
    tnumH(i)=t;
end

%% do Daily average
if doDaily
    tnum=floor(mean(tnumH));
    data=mean(dataH,3);
else
    tnum=tnumH;
    data=dataH;
end



end


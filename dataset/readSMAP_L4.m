function [data,tnum] = readSMAP_L4(t,dirSMAP,varargin)
% read SMAP L4 data download from NSIDC
% will hard code ny and nx to improve efficiency
% t - time num for a given date
% dirSMAP - kPath.SMAP, input to do parfor
% varargin{1} - version name

% data - all swath contains in that day
% lat,lon,tnum - 1d vector for lat, lon and time (hour, min, second)


tt=datenumMulti(t,1);

pnames={'version','field'};
dflts={'SPL4SMGP.003',[]};
[version,fieldName]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% hard code ny and nx
ny=1624;
nx=3856;

%% start
folder=[dirSMAP,version,filesep,datestr(tt,'yyyy.mm.dd'),filesep];
files = dir([folder,'*.h5']);
nfiles=length(files);
tnum=zeros(nfiles,1);

if nfiles~=0   
    data=zeros(ny,nx,nfiles)*nan;    
    
    for i=1:nfiles
        filename=[folder,files(i).name];
        C=strsplit(files(i).name,'_');
        tstr=C{5};
        tnumi=datenum(strrep(tstr,'T','-'),'yyyymmdd-HHMMSS');        
        datai=readSMAP(filename,version,'field',fieldName);
        if size(datai,1)~=ny || size(datai,2)~=nx
            error(['check ny and nx for t = ',num2str(t)])
        end
        data(:,:,i)=datai;
        tnum(i)=tnumi;
    end
else
    data=[];
    lat=[];
    lon=[];
    tnum=[];
    disp(['no file at ',num2str(t)]);
end

end


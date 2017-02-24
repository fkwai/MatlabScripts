function [data,lat,lon,tnum] = readSMAP_L2(t)
%read SMAP L2 data from Y:\SMAP\SPL2SMP.003
% t: time num for a given date
% data: all swath contains in that day
% lat,lon,tnum: 1d vector for lat, lon and time (hour, min, second)

tt=datenumMulti(t,1);

folder=['Y:\SMAP\SPL2SMP.003\',datestr(tt,'yyyy.mm.dd'),'\'];
files = dir([folder,'*.h5']);
nfiles=length(files);
tnum=zeros(nfiles,1);

if nfiles~=0
    % read grid from L3 to initial L2 data.
    [dataL3,latL3,lonL3] = readSMAP_L3(t);
    [ny,nx]=size(dataL3);
    data=zeros(ny,nx,nfiles)*nan;
    lat=nanmean(latL3,2);
    lon=nanmean(lonL3,1);
    
    for i=1:nfiles
        filename=[folder,files(i).name];
        C=strsplit(filename,'_');
        tstr=C{7};
        tnumi=datenum(strrep(tstr,'T','-'),'yyyymmdd-HHMMSS');
        
        [ datai,lati,loni ]=readSMAP(filename);
        datai2d=zeros(ny,nx)*nan;
        
        val=find(~isnan(datai));
        for j=1:length(val)
            templat=lati(val(j));
            templon=loni(val(j));
            tempdata=datai(val(j));
            datai2d(lat==templat,lon==templon)=tempdata;
        end
        data(:,:,i)=datai2d;
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


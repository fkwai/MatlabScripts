function [ Sta ] = readWeaMat( file, Sta )
%READWEAMAT Summary of this function goes here
%   read processed weather station matfile in mygui_dist_action


if(strcmp(file(end-2:end), 'mat'))
    temp=load(file);
    station=temp.station;   %preprocessed progame need to name structure station
else
    error('Not a mat weather station file');
end

ids=[station.id];

for i=1:length(Sta)
    ind=find(ids==Sta(i).id);
    Sta(i).datenums=station(ind).datenums;
    Sta(i).dates=str2num(datestr(station(ind).datenums,'yyyymmdd'));
    Sta(i).prcp=station(ind).prcp;
    Sta(i).rrad=station(ind).rrad;
    Sta(i).tmax=station(ind).tmax;
    Sta(i).tmin=station(ind).tmin;
    Sta(i).hmd=station(ind).hmd;
    Sta(i).awnd=station(ind).awnd;
end

end


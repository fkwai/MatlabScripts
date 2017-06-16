function [ Sta ] = readWeaMat( file, Sta )
%READWEAMAT Summary of this function goes here
%   read processed weather station matfile in mygui_dist_action


if(strcmp(file(end-2:end), 'mat'))
    temp=load(file);
    fAccept = {'station','Stations','S'}; % order of precedence
    f='';
    for i=1:length(fAccept)
        f = fAccept{i};
        if isfield(temp,f)
            station=temp.(f);   %preprocessed progame need to name structure station
            break
        end
    end
    display(['readWeaMat: using variable ',f,' from ',file]);
    if isempty(f)
        error(['Unable to find usable station variables from ',file]);
    end
else
    error('Not a mat weather station file');
end

ids=[station.id];

for i=1:length(Sta)
    ind=find(ids==Sta(i).id);
    Sta(i).datenums=station(ind).datenums;
    Sta(i).dates=str2num(datestr(station(ind).datenums,'yyyymmdd'));
    Sta(i).prcp=station(ind).prcp;
    if isfield(station(ind),'rad') && ~isempty(station(ind).rrad)
        Sta(i).rrad=station(ind).rrad;
    elseif isfield(station(ind),'Rad') && ~isempty(station(ind).Rad)
        Sta(i).rrad=station(ind).Rad;
    else
        warning(['station ',num2str(ind),': rad not found'])
    end
    Sta(i).tmax=station(ind).tmax;
    Sta(i).tmin=station(ind).tmin;
    Sta(i).hmd=station(ind).hmd;
    Sta(i).hli=station(ind).hli;
    Sta(i).Pa=station(ind).Pa;
    if ~isempty(station(ind).awnd)
        Sta(i).awnd=station(ind).awnd;
    elseif isfield(station(ind),'wnd') && ~isempty(station(ind).wnd)
        Sta(i).awnd=station(ind).wnd;
    else
        warning(['station ',num2str(ind),': wnd not found'])
    end
end

end


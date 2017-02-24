function [ station,SS ] = GP_comb_TRMM_CRUNCEP( CRUNCEPsta,TRMMsta )
%GP_COMB_TRMM_CRUNCEP Summary of this function goes here
%   Combine TRMM stations and CRUNCEP stations
% Example:
% load('Y:\Amazon\fromLBL\measured_wid\kuai\weaCRUNCEP.mat') 
% CRUNCEPsta=Stations;
% load('Y:\Amazon\fromLBL\measured_wid\kuai\weaTRMM.mat') 
% TRMMsta=Stations;

% ASSUMPTION: SAME DATENUM
field={'prcp','rrad','tmax','tmin','hmd','awnd','hli','Pa'};

latC = zeros(length(CRUNCEPsta), 1);
lonC = zeros(length(CRUNCEPsta), 1);
indC = zeros(length(CRUNCEPsta), 1);
for i = 1 : length(CRUNCEPsta)
    CRUNCEPsta(i).prcp=[];
    latC(i) = CRUNCEPsta(i).LatLong(1);
    lonC(i) = CRUNCEPsta(i).LatLong(2);
    indC(i) = i;
end
F = scatteredInterpolant(latC, lonC, indC, 'nearest');

for i=1:length(TRMMsta)
    lat=TRMMsta(i).LatLong(1);
    lon=TRMMsta(i).LatLong(2);
    ind=F(lat,lon);
    for k=2:length(field)
        TRMMsta(i).(field{k})=CRUNCEPsta(ind).(field{k});
    end
end

station=[CRUNCEPsta,TRMMsta];

for i=1:length(station)
    station(i).id=i;
    SS(i).Geometry='Point';
    SS(i).X=double(station(i).XYElev(1));
    SS(i).Y=double(station(i).XYElev(2));
    SS(i).ID=i;
    SS(i).LONGITUDE=double(station(i).LatLong(2));
    SS(i).LATITUDE=double(station(i).LatLong(1));
end


end


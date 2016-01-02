function [] = soil_properties(rawdir,boundingbox,proj,savedir)
% soil properties
% input: boundingbox = 2 x 2 array [lon_left, lon_right; lat_bottom, lat_up]

lon_left = boundingbox(1,1);
lon_right = boundingbox(2,1);
lat_bottom = boundingbox(1,2);
lat_up = boundingbox(2,2);

soitexfile=[rawdir,'\mksrf_soitex.10level.c010119.nc'];
soitexfile=checkMatNc(soitexfile);
orgnicfile=[rawdir,'\mksrf_organic_10level_5x5min_ISRIC-WISE-NCSCD_nlev7_c120830.nc'];
orgnicfile=checkMatNc(orgnicfile);

% lon = ncread(soitexfile, 'LON');
% lat = ncread(soitexfile, 'LAT');
longxy = readGPdata(soitexfile, 'LONGXY');
latixy = readGPdata(soitexfile, 'LATIXY');
% landmask = ncread(soitexfile, 'LANDMASK');
% dzsoi = ncread(soitexfile, 'DZSOI');
% dzsoi_om = ncread(orgnicfile, 'DZSOI');
zsoi = readGPdata(soitexfile, 'ZSOI');
% zsoi_om = ncread(orgnicfile, 'ZSOI');
% edgen = ncread(soitexfile, 'EDGEN');
% edgee = ncread(soitexfile, 'EDGEE');
% edges = ncread(soitexfile, 'EDGES');
% edgew = ncread(soitexfile, 'EDGEW');
mapunits = readGPdata(soitexfile, 'MAPUNITS');
pct_sand = readGPdata(soitexfile, 'PCT_SAND');
pct_clay = readGPdata(soitexfile, 'PCT_CLAY');
om = readGPdata(orgnicfile, 'ORGANIC');   % kg OM/m3


% extract for the watershed
lonind=find(longxy(:,1)>lon_left & longxy(:,1)<lon_right);
latind=find(latixy(1,:)>lat_bottom & latixy(1,:)<lat_up);
long_range=[lonind(1)-1;lonind;lonind(end)+1];  % 1 cell buffer
lati_range=[latind(1)-1,latind,latind(end)+1];
m_longxy = longxy(long_range,lati_range);
m_latixy = latixy(long_range,lati_range);

m_mapunits = mapunits(long_range,lati_range);
m_pct_clay = zeros(size(m_longxy, 1), size(m_longxy, 2), 10);
m_pct_sand = zeros(size(m_longxy, 1), size(m_longxy, 2), 10);
for i = 1 : size(m_longxy, 1)
    for j = 1 : size(m_longxy, 2)
        m_pct_clay(i, j, :) = pct_clay(m_mapunits(i, j), :);
        m_pct_sand(i, j, :) = pct_sand(m_mapunits(i, j), :);
    end
end
m_pct_silt = 100.0 - m_pct_clay - m_pct_sand;
m_om = double(om(long_range,lati_range,:));

m_ThetaS = zeros(size(m_pct_sand));
m_ThetaR = zeros(size(m_pct_sand));
m_Alpha = zeros(size(m_pct_sand));
m_nM = zeros(size(m_pct_sand));
m_bd = zeros(size(m_pct_sand));
m_pct_om = zeros(size(m_pct_sand));
m_zsoi = zeros(size(zsoi));
for i = 1 : size(m_pct_sand, 1)
    for j = 1 : size(m_pct_sand, 2)
        for k = 1 : size(m_pct_sand, 3)
            fid = fopen('ptf.in', 'w');
            fprintf(fid, '%2d %7.2f %20.15f %20.15f %20.15f %3d %3d %3d', ...
                1, zsoi(k)*100.0, m_pct_sand(i,j,k), m_pct_silt(i,j,k), m_pct_clay(i,j,k), ...
                -1, -1, -1);
            fclose(fid);
            status = system('PTFG.exe');
            if status
                error('PTFG running error!');
            end
            % only Wosten et al., 1999 has results for van Genuchten
            % parameters, so use the saturated water content to calculate
            % soil bulk density
            fid = fopen('WR.par', 'r');
            for nline = 1 : 20  % numbers on the 20th line
                tline = fgetl(fid);
            end
            fclose(fid);
            temp = str2num(tline);
            m_ThetaS(i,j,k) = temp(4);
            m_bd(i,j,k) = (1.0 - m_ThetaS(i,j,k)) * 2.7;    % g/cm3, from CLM
            % assuming 0.58 gC per gOM, from mksrf_organic_10level_5x5min_ISRIC-WISE-NCSCD_nlev7_c120830.nc
            m_pct_om(i,j,k) = 0.58 / m_bd(i,j,k) * m_om(i,j,k);
            % use soil bulk density and OM percentage calculated above to
            % re-estimate van Genuchten parameters
            fid = fopen('ptf.in', 'w');
            fprintf(fid, '%2d %7.2f %20.15f %20.15f %20.15f %20.15f %20.15f %3d', ...
                1, zsoi(k)*100.0, m_pct_sand(i,j,k), m_pct_silt(i,j,k), m_pct_clay(i,j,k), ...
                m_pct_om(i,j,k), m_bd(i,j,k), -1);
            fclose(fid);
            status = system('PTFG.exe');
            if status
                error('PTFG running error!');
            end
            % then use the parameters from Tomasella & Hodnett, 1998 for
            % tropical soil
            fid = fopen('WR.par', 'r');
            for nline = 1 : 39  % numbers are now on the 39th line for T&H 1998
                tline = fgetl(fid);
            end
            fclose(fid);
            temp = str2num(tline);
            m_zsoi(k) = temp(2);
            m_ThetaR(i,j,k) = temp(3);
            m_ThetaS(i,j,k) = temp(4);
            m_Alpha(i,j,k) = temp(5);
            m_nM(i,j,k) = temp(6);
        end
    end
end
m_KS = 86.4*25.4/3600*10.^(-0.6-0.0064*m_pct_clay+0.0126*m_pct_sand);  % unit: m/day
m_Lambda = exp(-(1.197+0.00417*m_pct_silt-0.0045*m_pct_clay+...
    0.000894*m_pct_silt.*m_pct_clay-0.00001*m_pct_silt.^2.*m_pct_clay));

% convert lat lon matrices to utm coord
m_East = zeros(size(m_longxy));
m_North = zeros(size(m_latixy));
for i = 1 : size(m_latixy, 1)
    for j = 1 : size(m_latixy, 2)
        [m_East(i, j), m_North(i, j)] = latlon2utm(m_latixy(i, j), m_longxy(i, j), proj.lon0,proj.hs);
    end
end

clear i j k fid status temp
save([savedir,'\soil_properties.mat'])
save([savedir,'\GW_K.mat'], 'm_East', 'm_North', 'm_KS', 'zsoi')

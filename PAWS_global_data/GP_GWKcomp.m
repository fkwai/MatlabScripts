function [K] = GP_GWKcomp( GWKfile,demfile,gwEin,savedir )
%GWKCOMP Summary of this function goes here
%   Detailed explanation goes here
% global dojie

if ischar(gwEin)
    gwEin=parseFiles(gwEin);
end

dem = readGrid(demfile,'%f');
%[Xr, Yr] = meshgrid(dem.x,dem.y);
if NEDorDEM( dem )
    dem.z=dem.z/100;    %ned
end
dem.z(dem.z>10000)=nan;
dem.z(dem.z<-1000)=nan;
%figure; pcolor(Xr, Yr, z); axis ij; shading flat

cellsize=zeros(length(gwEin)+1,1);
cellsize(1)=dem.cellsize;

for i=1:length(gwEin)
    if iscell(gwEin)
        Ein=gwEin{i};
    elseif isnumeric(gwEin)
        Ein=gwEin(i);
    end
    
    if isnumeric(Ein)
        Eout=dem;
        Eout.z=Eout.z-Ein;
    elseif ischar(Ein)
        num=str2double(Ein);
        if ~isnan(num)
            Ein=num;
            Eout=dem;
            Eout.z=Eout.z-Ein;
        else
            Eout=readGrid(Ein,'%f');
            Eout.z(Eout.z>10000)=nan;
            Eout.z(Eout.z<-5000)=nan;            
        end
    end
    E{i}=Eout;
    cellsize(i+1)=Eout.cellsize;
end

if std(cellsize)~=0    
    %find raster of largest cellsize and interpolate all to that. 
    cs_max=max([cellsize]);
    ind=find(cellsize==cs_max);
    if ind==1   %dem
        grid=dem;
    else
        grid=E{ind-1};
    end
    
    if ~isequal(grid.x,dem.x) || ~isequal(grid.y,dem.y)
        dem=interpGrid(dem,grid);
    end
    
    for i=1:length(E)
        Etemp=E{i};
        if ~isequal(grid.x,Etemp.x) || ~isequal(grid.y,Etemp.y)
            Etemp_intp=interpGrid(Etemp,grid);
            E{i}=Etemp_intp;
        end
    end
else
    grid=dem;
end

% if dojie
%     dem.z=round(dem.z);% compare with Jie
% end

load(GWKfile);
East=m_East';
North=m_North';

[Xr, Yr] = meshgrid(grid.x,grid.y);

% if dojie
%     [temp, R] = geotiffread('Y:\Amazon\fromLBL\Groundwater\SRTM_DEM_m100m\e0.tif');
%     [Xr, Yr] = meshgrid(linspace(R.XLimWorld(1),R.XLimWorld(2),R.RasterSize(2)),...
%         linspace(R.YLimWorld(1),R.YLimWorld(2),R.RasterSize(1)));
% end

KS = zeros([size(Xr), size(m_KS, 3)]);
for i = 1 : size(m_KS, 3)
    KS(:,:,i) = interp2_irreguler(East, North, m_KS(:,:,i)', Xr, Yr, 'nearest');
end

% depth of GW cell center below the last cell of soil
for i=1:length(E)
    z_GW{i} = 0.5 * (dem.z - E{i}.z - max(double(zsoi)));
end

S = area_slope(dem, grid);
% if dojie
%     dem2=dem;
%     dem2.z=flipud(dem2.z);
%     S2=area_slope(dem2, grid);
%     S=flipud(S2);
% end

K_0 = max(KS, [], 3);
f = 100 ./ (1 + 150 * S);

for i=1:length(E)
    K{i}=grid;
    K{i}.z = flipud(K_0) .* exp(-z_GW{i} ./ f) * 100;
end

mkdir([savedir,'\GW']);
for i=1:length(E)
    writeASCIIGrid([savedir,'\GW\E_',num2str(i-1),'.txt'],E{i});
    writeASCIIGrid([savedir,'\GW\K_',num2str(i-1),'.txt'],K{i});
    writeASCIIGrid([savedir,'\GW\H_',num2str(i-1),'.txt'],E{i});
end


end


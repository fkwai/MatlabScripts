function [ K0,K1 ] = GWKcomp( GWKfile,demfile,E0in,E1in,savedir )
%GWKCOMP Summary of this function goes here
%   Detailed explanation goes here

dem = readGrid(demfile,'%f');
%[Xr, Yr] = meshgrid(dem.x,dem.y);
if NEDorDEM( dem )
    dem.z=dem.z/100;    %ned
end
dem.z(dem.z>10000)=nan;
dem.z(dem.z<-1000)=nan;
%figure; pcolor(Xr, Yr, z); axis ij; shading flat

if isnumeric(E0in)
    E0=dem;
    E0.z=E0.z-E0in;
elseif ischar(E0in)
    E0=readGrid(E0in,'%f');
    E0.z(E0.z>10000)=nan;
    E0.z(E0.z<-1000)=nan;
end
if isnumeric(E1in)
    E1=dem;
    E1.z=E1.z-E1in;
elseif ischar(E1in)
    E1=readGrid(E1in,'%f');
    E1.z(E1.z>10000)=nan;
    E1.z(E1.z<-1000)=nan;
end

if E1.cellsize~=E0.cellsize || E1.cellsize~=dem.cellsize || E0.cellsize~=dem.cellsize
    raster=[dem,E0,E1];
    cellsize=max([raster.cellsize]);
    ind=find([raster.cellsize]==cellsize);
    grid=raster(ind(1));
    if ~isequal(grid.x,dem.x) || ~isequal(grid.y,dem.y)
        dem=interpGrid(dem,grid);
    end
    if ~isequal(grid.x,E0.x) || ~isequal(grid.y,E0.y)
        E0=interpGrid(E0,grid);
    end
    if ~isequal(grid.x,E1.x) || ~isequal(grid.y,E1.y)
        E1=interpGrid(E1,grid);
    end
end

load(GWKfile);
East=m_East';
North=m_North';
%figure; pcolor(East, North, m_KS(:,:,1)'); axis ij

[Xr, Yr] = meshgrid(dem.x,dem.y);
KS = zeros([size(Xr), size(m_KS, 3)]);
for i = 1 : size(m_KS, 3)
    KS(:,:,i) = interp2_irreguler(East, North, m_KS(:,:,i)', Xr, Yr, 'nearest');
end
%figure; pcolor(Xr, Yr, KS(:,:,1)); axis ij; shading flat


% depth of GW cell center below the last cell of soil
z0_GW = 0.5 * (dem.z - E0.z - max(double(zsoi)));
z1_GW = 0.5 * (dem.z - E1.z - max(double(zsoi)));

grid.x = dem.x;
grid.y = dem.y;
grid.cellsize = dem.cellsize;
grid.xllcorner = dem.xllcorner;
grid.yllcorner = dem.yllcorner;
grid.col = dem.col;
grid.row = dem.row;
S = area_slope(dem, grid);

K_0 = max(KS, [], 3);
f = 100 ./ (1 + 150 * S);
K0z = K_0 .* exp(-z0_GW ./ f) * 100;
%figure; pcolor(Xr, Yr, log10(K0)); axis ij; shading flat
K1z = K_0 .* exp(-z1_GW ./ f) * 100;
%figure; pcolor(Xr, Yr, log10(K1)); axis ij; shading flat

K0=dem;K0.z=K0z;
K1=dem;K1.z=K1z;

mkdir([savedir,'\GW']);
writeASCIIGrid([savedir,'\GW\E_0.txt'],E0);
writeASCIIGrid([savedir,'\GW\E_1.txt'],E1);
writeASCIIGrid([savedir,'\GW\K_0.txt'],K0);
writeASCIIGrid([savedir,'\GW\K_1.txt'],K1);
writeASCIIGrid([savedir,'\GW\H_0.txt'],E0);
writeASCIIGrid([savedir,'\GW\H_1.txt'],E1);


end

function [ ras ] = interpGrid( ras1, ras0 )
%interpolate grid of Env.OBJ.rGrid formate, ras1 to resolution and
%corrdinate of ras0

global Env
ras = Env.OBJ.rGrid; % Uniformize the format

ras.col=ras0.col;
ras.row=ras0.row;
ras.xllcorner=ras0.xllcorner;
ras.yllcorner=ras0.yllcorner;
ras.cellsize=ras0.cellsize;
ras.x=ras0.x;
ras.y=ras0.y;

[x,y]=meshgrid(ras1.x,ras1.y);
[xq,yq]=meshgrid(ras0.x,ras0.y);
ras.z=interp2(x,y,ras1.z,xq,yq);


end


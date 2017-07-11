function [f,cmap]=showMap(grid,y,x,varargin)
% a extend function use geoshow in matlab
% tsStr: contains 
% tsStr.t: tnum of ts
% tsStr.grid: a 3D grid with t in 3rd dimension
% tsStr.symb: symbol of this ts

pnames={'title','shapefile','colorRange','lonLim','latLim','newFig','nLevel','tsStr'};
dflts={[],[],[0,1],[],[],1,10,[]};

[strTitle,shapefile,colorRange,lonLim,latLim,newFig,nLevel,tsStr]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

[lonmesh,latmesh]=meshgrid(x,y);
if isempty(latLim)
    latLim=[min(y),max(y)];
end
if isempty(lonLim)
    lonLim=[min(x),max(x)];
end

if newFig==1
    f=figure('Position',[1,1,1200,800]);
end
axesm('MapProjection','eqdcylin','Frame','on','Grid','off', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south', ...
      'MapLatlimit', latLim, 'MapLonLimit', lonLim,...
      'MLabelLocation',[-120:10:70],'PLabelLocation',[25:5:50])
tightmap
% geoshow(latmesh,lonmesh,grid,'DisplayType','surface');
%geoshow(latmesh,lonmesh,grid,'DisplayType','texturemap');

levels = linspace(colorRange(1),colorRange(2), nLevel+1);
cmap = jet(length(levels) + 1);
cmap(1, :,:) = [1 1 1];
colormap(cmap)
Z = grid;
Z(Z < levels(1)) = 1;
Z(Z > levels(end)) = length(levels);
for k = 1:length(levels) - 1
    Z(grid >= levels(k) & grid <= levels(k+1)) = double(k) ;
end
geoshow(latmesh,lonmesh,uint8(Z),cmap);

if isempty(shapefile)
    landareas=shaperead('landareas.shp', 'UseGeo', true);
else
    landareas=shaperead(shapefile, 'UseGeo', true);
end
shape.lat = [landareas.Lat];
shape.long = [landareas.Lon];
geoshow(shape.lat, shape.long, 'Color', 'k')

if ~isempty(strTitle)
    title(strTitle)
end
if ~isempty(colorRange)
    caxis auto
    clevels =  cellstr(num2str(levels'));
    clevels = ['None'; clevels]';
    cb = lcolorbar(clevels,'Location','Horizontal');
    %set(cb,'position',[0.87 0.25 0.05 0.53])
end



end


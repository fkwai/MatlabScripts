function h=showMap(grid,y,x,varargin)
% a extend function use geoshow in matlab
% tsStr: contains 
% tsStr.t: tnum of ts
% tsStr.grid: a 3D grid with t in 3rd dimension
% tsStr.symb: symbol of this ts

pnames={'title','shapefile','colorRange','lonLim','latLim','newFig','tsStr'};
dflts={[],[],[],[],[],1,[]};

[strTitle,shapefile,colorRange,lonLim,latLim,newFig,tsStr]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

[lonmesh,latmesh]=meshgrid(x,y);
if isempty(latLim)
    latLim=[min(y),max(y)];
end
if isempty(lonLim)
    lonLim=[min(x),max(x)];
end

if newFig==1
    h=figure;
end
colorbar()
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south', ...
      'MapLatlimit', latLim, 'MapLonLimit', lonLim)
tightmap
% geoshow(latmesh,lonmesh,grid,'DisplayType','surface');
geoshow(latmesh,lonmesh,grid,'DisplayType','texturemap');

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
    caxis(colorRange)
end



end


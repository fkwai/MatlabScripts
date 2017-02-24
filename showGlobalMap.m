function [f] = showGlobalMap( grid,x,y,cellsize,varargin )
% show global map of given grid
% tsMap: a 3d grid with t as 3rd axis

pnames={'title','shapefile','color','lonLim','latLim','newFig','savename','figSize'};
dflts={[],[],[],[],[],1,[],[]};

[strTitle,shapefile,colorRange,lonLim,latLim,newFig,savename,figSize]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});


if newFig==1
    f=figure;
else
    f=gcf;
end

if ~isempty(colorRange)
    minv=colorRange(1);
    maxv=colorRange(2);
    grid(grid<minv)=minv;
    grid(grid>maxv)=maxv;
end

range=displayIndices(grid,[],x',y,cellsize,0);
if isempty(figSize)
    set(gcf, 'Position', get(0,'Screensize'))
else
    set(gcf, 'Position', figSize)
end
axis equal
if ~isempty(lonLim)
    xlim(lonLim);
end
if ~isempty(latLim)
    ylim(latLim);
end

xlabel('Longitude')
ylabel('Latitude')
Colorbar_reset(range)
%fixColorAxis([],range,11)
addDegreeAxis()

if isempty(shapefile)
    landareas=shaperead('landareas.shp', 'UseGeo', true);
else
    landareas=shaperead(shapefile, 'UseGeo', true);
end
shape.lat = [landareas.Lat];
shape.long = [landareas.Lon];
geoshow(shape.lat, shape.long, 'Color', 'k','LineWidth',2)

if ~isempty(strTitle)
    title(strTitle)
end

if ~isempty(savename)
    suffix = '.eps';
    fixFigure([],[savename,suffix]);
    Colorbar_reset(range,'nash')
    export_fig([savename,suffix],'-transparent');
    saveas(gcf, savename);
end



end


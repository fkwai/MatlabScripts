function showGrid( grid,x,y,cellsize,varargin)
%SHOWGRID Summary of this function goes here
%   Detailed explanation goes here

%% varargin
pnames={'titleStr','shapefile','colorRange','lonLim','latLim','newFig','tsStr'};
dflts={[],[],[],[],[],1,[]};

[titleStr,shapefile,colorRange,lonLim,latLim,newFig,tsStr]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

[lonmesh,latmesh]=meshgrid(x,y);
if isempty(latLim)
    latLim=[min(y)-cellsize,max(y)+cellsize];
end
if isempty(lonLim)
    lonLim=[min(x)-cellsize,max(x)+cellsize];
end

%% plot grid
if ~isempty(colorRange)
    minv=colorRange(1);
    maxv=colorRange(2);
    grid(grid<minv)=minv;
    grid(grid>maxv)=maxv;
end

if newFig==1
    f=figure('Position',[100,500,600,400]);
end
range=displayIndices(grid,[],x',y,cellsize,0);
axis equal
if ~isempty(lonLim)
    xlim(lonLim);
end
if ~isempty(latLim)
    ylim(latLim);
end

xlabel('Longitude')
ylabel('Latitude')
title(titleStr)
Colorbar_reset(range)
%fixColorAxis([],range,11)
%addDegreeAxis()

if isempty(shapefile)
    landareas=shaperead('landareas.shp', 'UseGeo', true);
else
    landareas=shaperead(shapefile, 'UseGeo', true);
end
shape.lat = [landareas.Lat];
shape.long = [landareas.Lon];
geoshow(shape.lat, shape.long, 'Color', 'k','LineWidth',2)

%% click to show TS
while(~isempty(tsStr))
    figure(f)
    [px,py]=ginput(1);
    %[px,py] = getpts(ax);
    ix=round((px-x(1))/cellsize)+1;
    iy=round((y(1)-py)/cellsize)+1;    
    [ny,nx]=size(grid);
    
    if ix<1 || ix>nx || iy<1 || iy>ny
        tsStr=[];
        if exist('fc','var')
            close(fc)
        end
    else
        legendStr=[];
        for k=length(tsStr):-1:1
            t=tsStr(k).t;
            legendStr=[legendStr,{tsStr(k).legendStr}];
            v=reshape(tsStr(k).grid(iy,ix,:),length(t),1);
            if ~exist('fc','var')
                fc=figure('Position',[100,100,1000,200]);
            else
                figure(fc)
            end
            ind=~isnan(v);
            plot(t(ind),v(ind),tsStr(k).symb,'LineWidth',2);hold on            
        end
        datetick('x');
        strtitle=['long=',num2str(x(ix)),'; lat=',num2str(y(iy)),'; '];
        title(strtitle);
        legend(legendStr,'Location','eastoutside')
        hold off
    end
end

end


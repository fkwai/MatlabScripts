function showGrid( grid,y,x,cellsize,varargin)
%SHOWGRID Summary of this function goes here
%   Detailed explanation goes here

%% varargin
pnames={'titleStr','shapefile','colorRange','lonLim','latLim','newFig','tsStr','tsStrFill','yRange'};
dflts={[],[],[],[],[],1,[],[],[]};

[titleStr,shapefile,colorRange,lonLim,latLim,newFig,tsStr,tsStrFill,yRange]=...
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
%range=displayIndices(grid,[],x',y,cellsize,0);
range=imagesc(x',y,grid);
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
%Colorbar_reset(range)
%fixColorAxis([],range,11)
%addDegreeAxis()

if ~isempty(shapefile)
    landareas=shaperead(shapefile, 'UseGeo', true);
    shape.lat = [landareas.Lat];
    shape.long = [landareas.Lon];
    geoshow(shape.lat, shape.long, 'Color', 'k','LineWidth',2)
end

%% click to show TS
while(~isempty(tsStr))
    figure(f)
    pause(0.1)
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
        
        %% fill of timeseries
        for k=length(tsStrFill):-1:1
            t=tsStrFill(k).t;
            legendStr=[legendStr,{tsStrFill(k).legendStr}];
            v1=reshape(tsStrFill(k).grid1(iy,ix,:),length(t),1);
            v2=reshape(tsStrFill(k).grid2(iy,ix,:),length(t),1);
            if ~exist('fc','var')
                fc=figure('Position',[100,100,1000,200]);
            else
                figure(fc)
            end
            ind=~isnan(v1+v2);
            vv=[v1(ind);flipud(v2(ind))];
            tt=[t(ind);flipud(t(ind))];
            fill(tt,vv,tsStrFill(k).color,'LineStyle','none');hold on
        end
        
        %% line of timeseries
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
            plot(t(ind),v(ind),tsStr(k).symb);hold on
        end
        
        
        ylim(yRange);
        datetick('x');
        strtitle=['long=',num2str(x(ix)),'; lat=',num2str(y(iy)),'; '];
        title(strtitle);
        legend(legendStr,'Location','eastoutside')
        hold off
    end
end

end


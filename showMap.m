function [f,cmap]=showMap(grid,y,x,varargin)
% a extend function use geoshow in matlab
% tsStr: contains
% tsStr.t: tnum of ts
% tsStr.grid: a 3D grid with t in 3rd dimension
% tsStr.symb: symbol of this ts

pnames={'title','shapefile','colorRange','Position','lonLim','latLim',...
    'newFig','nLevel','cmap','openEnds','tsStr','tsStrFill'};
dflts={[],[],[],[100,100,800,500],[],[],1,10,[],[],[],[]};

[strTitle,shapefile,colorRange,Position,lonLim,latLim,...
    newFig,nLevel,cmap,openEnds,tsStr,tsStrFill]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

[lonmesh,latmesh]=meshgrid(x,y);
if isempty(latLim)
    latLim=[min(y),max(y)];
end
if isempty(lonLim)
    lonLim=[min(x),max(x)];
end
if isempty(colorRange)
    colorRange=[min(grid(:)),max(grid(:))];
end
if isempty(openEnds)
    if colorRange(1)*colorRange(2)<0
        openEnds=[1 1];
    else
        openEnds=[0 0];
    end
end

if newFig==1
    f=figure('Position',Position);
end
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south', ...
    'MapLatlimit', latLim, 'MapLonLimit', lonLim,'LabelFormat','none',...
    'MLineLocation',[-120:10:70],'PLineLocation',[25:5:50],...
    'MLabelLocation',[-120:10:70],'PLabelLocation',[25:5:50],'FontSize',16);
objLabel=findobj('Tag','MLabel');
set(objLabel,'VerticalAlignment','middle');

tightmap

insert0 = 1;
[tickP2,tickV2,tickL2,Z,nColor] = colorBarRange(grid,colorRange,nLevel,openEnds,'insert0',insert0);
sel=2;
v= tickV2(1:sel:end);
st=1;
if ~any(abs(v)<1e-10)
    st=2;
end
tick = tickP2(st:sel:end);
tickL = tickL2(st:sel:end);
tickV = tickV2(st:sel:end);

if isempty(cmap)
    cmap = jet(nColor);
    cmap(1, :,:) = [1 1 1]; % for NaN converted 0's in Z
end
colormap(cmap);
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
    %caxis auto
    caxis([0,nColor])
    h=colorbar('southoutside','Ticks',tick,'TickLabels',tickL);
    set(h,'Position',[0.13,0.08,0.77,0.04],'fontsize',20,...
        'Ticklength',0.034,'LineWidth',1.5)
end
set(gcf,'color','w');


%% click to show TS
fc=[];
while(~isempty(tsStr))
    figure(f)
    pause(0.1)
    [py,px]=inputm(1);
    if isempty(px)
        tsStr=[];
        close(fc);
    else
        [dx,ix]=min(abs(px-x));
        [dy,iy]=min(abs(py-y));        
        strTitle=['lon=',num2str(x(ix)),'; lat=',num2str(y(iy)),'; '];
        if ~isnan(grid(iy,ix))
            fc= plotTsStr( iy,ix,tsStr,tsStrFill,'fc',fc,'strTitle',strTitle);        
        end
    end
end


end


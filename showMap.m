function [f,cmap]=showMap(grid,y,x,varargin)
% a extend function use geoshow in matlab
% tsStr: contains 
% tsStr.t: tnum of ts
% tsStr.grid: a 3D grid with t in 3rd dimension
% tsStr.symb: symbol of this ts

pnames={'title','shapefile','colorRange','Position','cbTitle','lonLim','latLim','newFig','nLevel','tsStr','cmap','openEnds'};
dflts={[],[],[0,1],[1,1,800,500],'[-]',[],[],1,10,[],[],[1 1]};

[strTitle,shapefile,colorRange,Position,cbTitle,lonLim,latLim,newFig,nLevel,tsStr,cmap,openEnds]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

[lonmesh,latmesh]=meshgrid(x,y);
if isempty(latLim)
    latLim=[min(y),max(y)];
end
if isempty(lonLim)
    lonLim=[min(x),max(x)];
end

if newFig==1
    f=figure('Position',Position);
end
axesm('MapProjection','eqdcylin','Frame','on','Grid','off', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south', ...
      'MapLatlimit', latLim, 'MapLonLimit', lonLim,'LabelFormat','none',...
      'MLabelLocation',[-120:10:70],'PLabelLocation',[25:5:50],'FontSize',16)
tightmap
% geoshow(latmesh,lonmesh,grid,'DisplayType','surface');
%geoshow(latmesh,lonmesh,grid,'DisplayType','texturemap');

%
levels = linspace(colorRange(1),colorRange(2), nLevel-1);
levels(levels<1e-10&levels>-1e-10)=0;

colormap(cmap);
Z = zeros(size(grid));
Z(grid < levels(1)) = 1;
%Z(grid >= levels(end)) = length(levels);
for k = 1:length(levels) - 1
    Z(grid >= levels(k) & grid < levels(k+1)) = double(k+1) ;
end
Z(grid >= levels(end)) = length(levels)+2;
%
%[tick,tickL,Z,nColor] = colorBarRange(colorRange, nLevel, openEnds, grid);
if isempty(cmap)
    %cmap = jet(nColor);
    cmap = jet(nLevel+1);
    if openEnds(1)
        cmap(1, :,:) = [1 1 1];
    end
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
%sel = 2; tick = tick(sel:sel:end); tickL = tickL(sel:sel:end);
if ~isempty(colorRange)
    caxis auto
    clevels =cellfun(@num2str,num2cell(levels),'UniformOutput',false);
    clevels(2:2:end)={''};
    clevels = [''; clevels]';
    itick=1/(length(levels)+2);
    ctick=itick*[2:2:nLevel];
    h=colorbar('southoutside','XTick',ctick,'XTickLabel',clevels(1:2:end),...
       'YTick',[],'YTickLabel',[]);
%     h=colorbar('southoutside','XTick',tick,'XTickLabel',tickL,...
%         'YTick',[],'YTickLabel',[]);
    set(h,'Position',[0.13,0.08,0.77,0.04],'fontsize',16)
    %cb = lcolorbar('Ticks',1.5:nLevel-0.5,'Location','Horizontal');  
    
    %cb = lcolorbar(clevels,'TitleString',cbTitle);  
end



end


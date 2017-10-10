function [f,cmap]=showMap(grid,y,x,varargin)
% a extend function use geoshow in matlab
% tsStr: contains 
% tsStr.t: tnum of ts
% tsStr.grid: a 3D grid with t in 3rd dimension
% tsStr.symb: symbol of this ts

pnames={'title','shapefile','colorRange','Position','lonLim','latLim',...
    'newFig','nLevel','cmap','openEnds'};
dflts={[],[],[0,1],[100,100,800,500],[],[],1,10,[],[1 1]};

[strTitle,shapefile,colorRange,Position,lonLim,latLim,...
    newFig,nLevel,cmap,openEnds]=...
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
    'MLabelLocation',[-120:10:70],'PLabelLocation',[25:5:50],'FontSize',16);
objLabel=findobj('Tag','MLabel');
set(objLabel,'VerticalAlignment','middle');

tightmap
% geoshow(latmesh,lonmesh,grid,'DisplayType','surface');
%geoshow(latmesh,lonmesh,grid,'DisplayType','texturemap');

%CP: plotOpt=0 new control of color scale: with ends
plotOpt=0; %
if plotOpt==1
    levels = linspace(colorRange(1),colorRange(2), nLevel-1);
    levels(levels<1e-10&levels>-1e-10)=0;
    
    colormap(cmap);
    Z = zeros(size(grid));
    Z(grid < levels(1)) = 1;
    %Z(grid >= levels(end)) = length(levels);
    for k = 1:length(levels) - 1
        Z(grid >= levels(k) & grid < levels(k+1)) = double(k+1) ;
    end
    Z(grid >= levels(end)) = length(levels)+1;
else
    insert0 = 1;
    [tickP2,tickV2,tickL2,Z,nColor] = colorBarRange(colorRange, nLevel, openEnds, grid, insert0);
    sel = 2; v = tickV2(1:sel:end); 
    st  = 1; if ~any(abs(v)<1e-10), st=2; end
    tick = tickP2(st:sel:end); tickL = tickL2(st:sel:end);
    tickV = tickV2(st:sel:end);
end
if isempty(cmap)
    if plotOpt==1
        cmap = jet(nLevel+1); % added one for NaNs
    else
        cmap = jet(nColor); % NaN's already considered in colorBarRange
        % insert zeros if it is in range
%         [k,tickV3,tickP3] = insertZero(tickV2,tickP2);        
%         if ~isempty(k)
%             tickL3 = [tickL2(1:k) '0' tickL2(k+1:end)];
%         end
        
    end
    %if openEnds(1)
        cmap(1, :,:) = [1 1 1]; % for NaN converted 0's in Z
    %end
end
colormap(cmap);
% NaN's are treated as 0's, which get the first color
% therefore, one color is reserved for NaN's.
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
    if plotOpt==1
        clevels =cellfun(@num2str,num2cell(levels),'UniformOutput',false);
        clevels(2:2:end)={''};
        clevels = [''; clevels]';%??? doesn't match anymore?
        itick=1/(length(levels)+2);
        ctick=itick*[2:2:nLevel];
        h=colorbar('southoutside','XTick',ctick,'XTickLabel',clevels(1:2:end),...
            'YTick',[],'YTickLabel',[]);
    else
        h=colorbar('southoutside','Ticks',tick,'TickLabels',tickL);
    end
    set(h,'Position',[0.13,0.08,0.77,0.04],'fontsize',20,...
        'Ticklength',0.034,'LineWidth',1.5)
    %cb = lcolorbar('Ticks',1.5:nLevel-0.5,'Location','Horizontal');  
    
    %cb = lcolorbar(clevels,'TitleString',cbTitle);  
end

set(gcf,'color','w');


end


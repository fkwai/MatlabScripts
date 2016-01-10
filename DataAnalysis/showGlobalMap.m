function [f,range] = showGlobalMap( grid,x,y,cellsize,fname,varargin )
% show global map of given grid
% varargin{1}: title
% varargin{2}: range eg [0,1]



f=figure;

titlestr=[];
if length(varargin)>0
    titlestr=varargin{1};
end

gridrange=[];
if length(varargin)>1 && ~isempty(varargin{2})
    gridrange=varargin{2};
    minv=gridrange(1);
    maxv=gridrange(2);
    grid(grid<minv)=minv;
    grid(grid>maxv)=maxv;
end
    
range=displayIndices(grid,[],x,y,cellsize,0);
axis equal tight
title(titlestr)
xlabel('Longitude')
ylabel('Latitude')
set(gcf, 'Position', get(0,'Screensize'))
Colorbar_reset(range)

if ~isempty(fname)
    suffix = '.eps';
    fixFigure([],[fname,suffix]);
    saveas(gcf, fname);
end

end


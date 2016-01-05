function showGrid_3d( grid ,x,y,grid3d,t,varargin)
% grid: 2d grid that show on map
% x y: lon and lat
% grid3d: 3d grid and ts of select point will be plotted. 
% t: t of 3d grid


f=figure
xx=sort(unique(x));
yy=sort(unique(y));
range=displayIndices(flipud(grid),[],xx,yy,1,0);
h = colorbar;
YTick=get(h,'YTick');
p = linearIntp(YTick,[0,1],range);
for i=1:length(p), labels{i}=num2str(p(i),4); end
set(h,'YTickLabel',labels)
axis equal tight

while(~isempty(grid3d))
    figure(f)
    [px,py]=ginput(1);
    %[px,py] = getpts(ax);
    cx=floor(px)+(xx(2)-xx(1))/2;
    cy=floor(py)+(yy(2)-yy(1))/2;

    i=find(x==cx);    
    j=find(y==cy)
    [ny,nx,nz]=size(grid3d);
    ts.v=reshape(grid3d(j,i,:),nz,1);
    ts.t=t;
    
    figure
    hold on
    plotTS(ts,'-b')
    strtitle=['long=',num2str(cx),'; lat=',num2str(cy),'; '];
    
    if length(varargin)>0        
        for i=1:length(varargin)
            name=inputname(i+4);
            var=varargin{i};
            v=var(index);
            strtitle=[strtitle,'; ',name,'=',num2str(v)];
        end
    end
    title(strtitle);
    hold off
    
end

end


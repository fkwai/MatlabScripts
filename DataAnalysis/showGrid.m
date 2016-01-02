function showGrid( grid ,x,y,ts,varargin)
%SHOWGRID Summary of this function goes here
%   Detailed explanation goes here


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

while(~isempty(ts))
    figure(f)
    [px,py]=ginput(1);
    %[px,py] = getpts(ax);
    cx=floor(px)+(xx(2)-xx(1))/2;
    cy=floor(py)+(yy(2)-yy(1))/2;

    index=find(x==cx&y==cy);

    figure
    hold on
    plotTS(ts(index),'-b')
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


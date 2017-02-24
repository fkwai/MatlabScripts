function Colorbar_reset(range,varargin)

ctitle=[];
if ~isempty(varargin)
    ctitle=varargin{1};
end

h = colorbar;
YTick=get(h,'YTick');
p = linearIntp(YTick,[0,1],range);
for i=1:length(p), 
    labels{i}=num2str(p(i),'%.2f');     
    %labels{i}=num2str(p(i));     
end
set(h,'YTick',YTick,'YTickLabel',labels,'fontsize',15);

if ~isempty(ctitle)    
    title(h,ctitle);
end

end


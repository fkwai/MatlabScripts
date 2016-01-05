function Colorbar_reset(range)
h = colorbar;
YTick=get(h,'YTick');
p = linearIntp(YTick,[0,1],range);
for i=1:length(p), labels{i}=num2str(p(i),4); end
set(h,'YTickLabel',labels)

end


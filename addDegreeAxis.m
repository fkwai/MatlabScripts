function addDegreeAxis()
% add degree to x and y axis (for maps)

xt=get(gca,'xtick');
for k=1:numel(xt)
    xt1{k}=sprintf('%d°',xt(k));
end
set(gca,'xticklabel',xt1);

yt=get(gca,'ytick');
for k=1:numel(yt)
    yt1{k}=sprintf('%d°',yt(k));
end
set(gca,'yticklabel',yt1);

end


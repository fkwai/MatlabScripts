function clusterPlotInd( X,T,class,n,varargin )
% plot n random individual of given class.

if ~isempty(varargin)
    center=varargin{1}; %Kmean have a modified center
else
    center=[];
end

tab=tabulate(T);
ind=find(tab(:,1)==class);
nclass=tab(ind,2);
r=round(rand(n,1)*nclass);

figure;
class=tab(ind,1);
nind=tab(ind,2);
XX=X(T==class,:);
boxplot(XX);hold on
if ~isempty(center)
    plot(center(class,:),'*-r');hold on
end
[nindAll,nattr]=size(X);
axis([0,nattr,-1,1])
plot([0 nattr],[0 0],'k');hold on
title(['class ',num2str(class),' size: ',num2str(nind),'/',num2str(nindAll)])
for i=1:length(r)
    plot(XX(r(i),:)',getS(i,'l'))
end
hold off

end


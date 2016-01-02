function clusterPlot( X,T,varargin )
%CLUSTERPLOT Summary of this function goes here
%   Detailed explanation goes here

if ~isempty(varargin)
    center=varargin{1}; %Kmean have a modified center
else
    center=[];
end

nclass=length(unique(T(~isnan(T))));
tab=flipud(sortrows(tabulate(T),2));
%tab=tabulate(T);

[nindAll,nattr]=size(X);

figure;
hist(T,length(unique(T)))
title(['num of classes: ',num2str(nclass)])

figure;
if nclass>10 
    n=10;
else
    n=nclass;
end
for i=1:n
    subplot(ceil(n/2),2,i)
    class=tab(i,1);
    nind=tab(i,2);
    ind=find(T==class);
    XX=X(ind,:);
    if length(ind)>1
        boxplot(XX);hold on
    else
        plot([1:nattr],XX);hold on
    end
    if ~isempty(center)
        plot(center(class,:),'*-r');hold on
    end
    axis([0,nattr,-1,1])
    plot([0 nattr],[0 0],'k');hold on
    title(['class ',num2str(class),' size: ',num2str(nind),'/',num2str(nindAll)])
    hold off
end
nindclass=sum(tab(1:n,2));
disp(['classed: ',num2str(nindclass),'/',num2str(nindAll)]);


end


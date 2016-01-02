function plotHist( X )
%PLOTHIST Summary of this function goes here
%   Detailed explanation goes here
X1=X(:,1:15);
X2=X(:,16:30);

c=jet(15);
h1= histc(X1,[-1:0.1:1]);
h2= histc(X2,[-1:0.1:1]);

figure
for i=1:15
    plot([-1:0.1:1],h1(:,i),'Color',c(i,:));hold on
    str{i}=['percentile ',num2str(i)];
end
title('USGS max CORR')
legend(str)

figure
for i=1:15
    plot([-1:0.1:1],h2(:,i),'Color',c(i,:));hold on
    str{i}=['percentile ',num2str(i)];

end
title('USGS min CORR')
legend(str)

end


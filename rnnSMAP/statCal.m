function stat=statCal(x,y)
% calculate nash, R2, bias, rmse between two time series
% x: [#time step * #points]
% y: [#time step * #points]

[nt,nInd]=size(x);
nModel=1;
nash=zeros(nInd,nModel)*nan;
rsq=zeros(nInd,nModel)*nan;
bias=zeros(nInd,nModel)*nan;
rmse=zeros(nInd,nModel)*nan;

indV=find(sum(isnan(x),1)./nt<0.1); % assume x is complete time seris and remove ones with too many nans

nashTemp=[1-nansum((x-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2)]';
rsqTemp=zeros(nInd,1);
for j=1:nInd
    %rsqTemp(j)=sqrt(RsqCalculate(y(:,j),x(:,j)));
    rsqTemp(j)=RsqCalculate(y(:,j),x(:,j),1);
end
biasTemp=nanmean(x-y)';
rmseTemp=sqrt(nanmean((x-y).^2))';
nash(indV)=nashTemp(indV);
rsq(indV)=rsqTemp(indV);
bias(indV)=biasTemp(indV);
rmse(indV)=rmseTemp(indV);


stat.nash=nash;
stat.rsq=rsq;
stat.bias=bias;
stat.rmse=rmse;

end


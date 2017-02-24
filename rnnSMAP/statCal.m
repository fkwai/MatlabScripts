function stat=statCal(x,y)
% calculate nash, R2, bias, rmse between two time series
% x: [#time step * #points * #models]
% y: [#time step * #points]

[nt,nInd,nModel]=size(x);
nash=zeros(nInd,nModel)*nan;
rsq=zeros(nInd,nModel)*nan;
bias=zeros(nInd,nModel)*nan;
rmse=zeros(nInd,nModel)*nan;

for k=1:nModel
    nashTemp=[1-nansum((x(:,:,k)-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2)]';    
    rsqTemp=zeros(nInd,1);
    for j=1:nInd
        rsqTemp(j)=RsqCalculate(y(:,j),x(:,j,k));
    end
    biasTemp=nanmean(x(:,:,k)-y)';
    rmseTemp=sqrt(nanmean((x(:,:,k)-y).^2))';
    nash(:,k)=nashTemp;
    rsq(:,k)=rsqTemp;
    bias(:,k)=biasTemp;
    rmse(:,k)=rmseTemp;
end

stat.nash=nash;
stat.rsq=rsq;
stat.bias=bias;
stat.rmse=rmse;

end


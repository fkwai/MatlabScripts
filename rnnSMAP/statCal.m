function stat=statCal(x,y,varargin)
% calculate nash, R2, bias, rmse between two time series
% x: [#time step * #points]
% y: [#time step * #points]
% rmStd: remove points within [mean-n*std,mean+n*std]

pnames={'rmStd'};
dflts={0};
[rmStd]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});


[nt,nInd]=size(x);
nash=zeros(nInd,1)*nan;
rsq=zeros(nInd,1)*nan;
bias=zeros(nInd,1)*nan;
rmse=zeros(nInd,1)*nan;

if rmStd~=0
    lb=nanmean(x)-rmStd*std(x);
    ub=nanmean(x)-rmStd*std(x);
    indRm=find(x>lb&x<ub);
    x(:,indRm)=nan;
    y(:,indRm)=nan;
end

%indV=find(sum(isnan(x),1)./nt<0.1); % assume x is complete time seris and remove ones with too many nans
indV=1:size(x,2);
% not doing anything actually

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


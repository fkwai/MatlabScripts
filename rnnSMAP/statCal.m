function stat=statCal(x,y,varargin)
% calculate nash, R2, bias, rmse between two time series
% x: [#time step * #points]
% y: [#time step * #points]
% rmStd: remove points within [mean-n*std,mean+n*std]

pnames={'rmStd','batch'};
dflts={0,[]};
[rmStd,xBatch]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});


%% stat of x
[nt,nInd]=size(x);
nash=zeros(nInd,1)*nan;
rsq=zeros(nInd,1)*nan;
bias=zeros(nInd,1)*nan;
rmse=zeros(nInd,1)*nan;
ubrmse=zeros(nInd,1)*nan;
mse=zeros(nInd,1)*nan;
varRes=zeros(nInd,1)*nan;

if rmStd~=0
    lb=nanmean(y)-rmStd*nanstd(y);
    ub=nanmean(y)+rmStd*nanstd(y);
    x(y>lb&y<ub)=nan;
    y(y>lb&y<ub)=nan;
end

%indV=find(sum(isnan(x),1)./nt<0.1); % leave NaN when nan in x >10%. 
indV=1:nInd;

% need to do one by one
rsqTemp=zeros(nInd,1);
varResTemp=zeros(nInd,1);
for j=1:nInd
    %rsqTemp(j)=sqrt(RsqCalculate(y(:,j),x(:,j)));
    xx=x(:,j);
    yy=y(:,j);
    ind=find(~isnan(xx)&~isnan(yy));
    rsqTemp(j)=RsqCalculate(yy,xx,1);
    varResTemp(j)=var(xx(ind)-yy(ind));
end

meanX=repmat(nanmean(x,1),[nt,1]);
meanY=repmat(nanmean(y,1),[nt,1]);
nashTemp=[1-nansum((x-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2)]';
biasTemp=nanmean(x-y)';
ubrmseTemp=sqrt(nanmean(((x-meanX)-(y-meanY)).^2))';
rmseTemp=sqrt(nanmean((x-y).^2))';
mseTemp=nanmean((x-y).^2)';

nash(indV)=nashTemp(indV);
rsq(indV)=rsqTemp(indV);
bias(indV)=biasTemp(indV);
rmse(indV)=rmseTemp(indV);
ubrmse(indV)=ubrmseTemp(indV);
mse(indV)=mseTemp(indV);
varRes(indV)=varResTemp(indV);



%% return results
stat.nash=nash;
stat.rsq=rsq;
stat.bias=bias;
stat.rmse=rmse;
stat.ubrmse=ubrmse;
stat.mse=mse;
stat.varRes=varRes;


end


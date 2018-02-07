function out = statCal_hindcast( tsSite,tsLSTM,tsSMAP )
% calculate stat of hindcast result given ts of site, lstm and smap
% out : a 3*4 matrix
% x axis - 
% 1. test(LSTM vs site), 2. train(LSTM vs site), 
% 3. train(LSTM vs site), 4. train(LSTM vs site)
% y axis - rmse, bias, rsq


t1=tsSite.t(1);
t2=tsSMAP.t(1);
t3=min(tsSMAP.t(end),tsSite.t(end));
v1LSTM=tsLSTM.v(tsLSTM.t>=t1&tsLSTM.t<=t2);
v2LSTM=tsLSTM.v(tsLSTM.t>=t2&tsLSTM.t<=t3);
v1Site=tsSite.v(tsSite.t>=t1&tsSite.t<=t2);
v2Site=tsSite.v(tsSite.t>=t2&tsSite.t<=t3);
v2SMAP=tsSMAP.v(tsSMAP.t>=t2&tsSMAP.t<=t3);

temp=zeros(4,3)*nan;
temp(:,1)=statCalTemp(v1LSTM,v1Site);
temp(:,2)=statCalTemp(v2LSTM,v2Site);
temp(:,3)=statCalTemp(v2SMAP,v2Site);
out.rmse=temp(1,:);
out.bias=temp(2,:);
out.rsq=temp(3,:);
out.ubrmse=temp(4,:);


end

function [outTemp]=statCalTemp(a,b)
[nt,nInd]=size(a);
ind=~isnan(a)&~isnan(b);
meanA=repmat(nanmean(a(ind),1),[nt,1]);
meanB=repmat(nanmean(b(ind),1),[nt,1]);
ubrmse=sqrt(nanmean(((a-meanA)-(b-meanB)).^2))';
rmse=sqrt(nanmean((a-b).^2));
bias=nanmean(a-b);
rsq=RsqCalculate(a,b,1);

outTemp=[rmse;bias;rsq;ubrmse];
end
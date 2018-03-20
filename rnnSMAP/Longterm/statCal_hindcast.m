function out = statCal_hindcast( tsSite,tsLSTM,tsSMAP )
% calculate stat of hindcast result given ts of site, lstm and smap
% out : a 3*4 matrix
% x axis -
% 1. test(LSTM vs site), 2. train(LSTM vs site),
% 3. train(LSTM vs site), 4. train(LSTM vs site)
% y axis - rmse, bias, rsq


[outSite,outLSTM,outSMAP ] = splitSiteTS(tsSite,tsLSTM,tsSMAP);

if ~isempty(outLSTM)    
    temp1=statCalTemp(outLSTM.v1,outSite.v1);
    temp2=statCalTemp(outLSTM.v2,outSite.v2);
    temp3=statCalTemp(outSMAP.v,outSite.v2);
    out=[temp1;temp2;temp3];
else
    out=[];
end

end

function [outTemp]=statCalTemp(a,b)
[nt,nInd]=size(a);
ind=~isnan(a)&~isnan(b);
meanA=repmat(nanmean(a(ind),1),[nt,1]);
meanB=repmat(nanmean(b(ind),1),[nt,1]);
ubrmse=sqrt(nanmean(((a-meanA)-(b-meanB)).^2))';
rmse=sqrt(nanmean((a-b).^2));
bias=nanmean(a-b);

aa=a(~isnan(a)&~isnan(b));
bb=b(~isnan(a)&~isnan(b));
if isempty(aa) || isempty(bb)
    rho=nan;
    rhoS=nan;
else
    rho=corr(aa,bb);
    rhoS=corr(aa,bb,'type','Spearman');
end

outTemp=struct('rmse',rmse,'bias',bias,'ubrmse',ubrmse,'rho',rho,'rhoS',rhoS);
end
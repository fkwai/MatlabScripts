function [ out,lb,ub,data_mean ] = normalize_perc( data,perc )
% normalize based on percentile (to [-1 1]). 
% shrink lower and upper bound in case of abnormal values. 
% for exmaple perc=0.1. lower bound will be 0.1 percentile and upper bound
% will be 0.9 percentile. 

[nr,nc]=size(data);
data_1d=reshape(data,[nr*nc,1]);
data_mean=mean(data_1d);
data_anorm_1d=data_1d-data_mean;
lb=prctile(data_anorm_1d,perc);
ub=prctile(data_anorm_1d,100-perc);

out=(data-data_mean-lb)./(ub-lb)*2-1;

end


function [X_train,X_test,T_train,T_test]=splitDataset( X,T,perc_train )
%SPLITDATASET Summary of this function goes here
%   Detailed explanation goes here
[nr,nc]=size(X);
ntrain=floor(nr*perc_train);

indtrain=randsample(nr,ntrain);
indtest=1:nr;indtest(indtrain)=[];

X_train=X(indtrain,:);
X_test=X(indtest,:);

T_train=T(indtrain,:);
T_test=T(indtest,:);

end


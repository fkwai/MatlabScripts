function [yfit,R2,b] = regress_kuai( Y,X,varargin )
% Doing linear regression. Also allow to feed in b and compute yfit and Rsq

if ~isempty(varargin)
    b=varargin{1};
else
    b=X\Y;
end

yfit=X*b;
SSE=sum((Y-yfit).^2);
SSTO=(length(Y)-1)*var(Y);
R2=1-SSE/SSTO;

% [n,p]=size(X);
% AIC=n*log(SSE/n)+2*(p+1);
% AICc=AIC+2*p*(p+1)/(n-p-1);
end


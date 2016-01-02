function [ rmse ] = SurModel( coef, Amp, Ep, P, Xe, Xc, obs )
%Employ surrogate model describe in poster

nbasin=length(Amp)
nXe=size(Xe,2);
nXc=size(Xc,2);
n=length(coef);

if n~=1+2*nXe+2*nXc
    error('coefficient and predictors do not match')
end

phi = coef(1);
coeftemp=reshape(coef(2:end),[(n-1)/2]);
a=coeftemp(:,1);
b=coeftemp(:,2);


end


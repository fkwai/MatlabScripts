function [rmse,y]= additiveSurModel(P, Obs, Sur, cFact, uncFact)
% additive surrogate model
% P(1) is phi=a^{bar}/b^{bar}, to be loaded on Surrogate
% P(2: (m+1)): loading for correlated (with surrogate) variables (a)
% P(m+2:2m+1): loading in the surrogate equation (b)
% P(2m+2:end): loading for uncorrelated (with surrogate) variables. Use
% unFact=0 to disable this option

[nr,m]=size(cFact);
np = length(P);

phi = P(1);
a = P(2:m+1);
b = P(m+2:2*m+1);

if np> 2*m+1
    c = P(2*m+2:end);
else
    c = 0;
end

y = phi*Sur;
for i=1:m
    fact = (a(i)-phi*b(i))*cFact(:,i);
    y = y + fact;
end

if c >0
    for i=1:length(c)
        fact = c(i)*uncFact(:,i);
        y = y + fact;
    end
end


rmse = sqrt((y - Obs).^2/length(Obs));
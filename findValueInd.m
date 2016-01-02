function [ ind ] = findValueInd( X,v )
% find index of input value in plot
% X: data array
% v: value in plot

v = abs(v); %in case of negative numbers
n=0;
while (floor(v*10^n)~=v*10^n)
    n=n+1;
end

ind=find(X<v+0.5/10^n&X>v-0.5/10^n);


end


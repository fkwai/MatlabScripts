function [ y ] = nDigit(x,nD)
% decrease precision of x to nD digits. Used for intersect, find, etc. 
y=round(x*10^nD)/10^nD;
end


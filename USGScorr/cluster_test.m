function [nb,nbSize]=cluster_test(X)
%CLUSTER_TEST Summary of this function goes here
%   Detailed explanation goes here

the=0.15;
bound=1; 
[nind,nband]=size(X);

nb=cell(nind,1);
nbSize=zeros(nind,1);
for i=1:nind
    x=X(i,:);    
    XX=repmat(x,[nind,1]);
    diff=abs(X-XX);
    bdiff=sum(double(diff<=the),2);
    tempN=find(bdiff>=nband*bound);
    tempNS=length(tempN);
    nb{i}=tempN;
    nbSize(i)=tempNS;
end

end


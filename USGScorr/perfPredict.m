function [ perf,perfclass] = perfPredict( pT,T,varargin )
%calculate accuracy and plot for prediction of test dataset.
% varargin{1}: number of classes, in case that test set do not contain all
% classes.
% varargin{2}: calculate accuracy of given class


nclass=length(unique(T(~isnan(T))));
perf=length(find(pT==T))/length(T);

if length(varargin)>0
    if ~isempty(varargin{1})
        nclass=varargin{1};
    end
end

if length(varargin)>1    
    if ~isempty(varargin{2})
        class=varargin{2};
        ind=find(T==class);
        perf=length(find(pT(ind)==T(ind)))/length(T(ind));
    end
end

tab=tabulate(T);

perfclass=zeros(nclass,1);
for i=1:nclass
    x=pT(T==i);
    y=T(T==i);
    perfclass(i)=length(find(x==y))/length(y);
end




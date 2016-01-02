function map = perfPredictMap( pT,T,varargin )
%ERRORREC Summary of this function goes here
%   Detailed explanation goes here

%nclass=length(unique(T(~isnan(T))));
nclass=maxALL([T,pT]);
nind=length(T);

if length(varargin)>0
    if ~isempty(varargin{1})
        nclass=varargin{1};
    end
end

if length(varargin)>1
    doplot=varargin{2};
else
    doplot=1;
end

map=zeros(nclass);
for i=1:nind
    map(T(i),pT(i))=map(T(i),pT(i))+1;
end
%map=map/nind;
if doplot
    showErrMap(map);
end


end


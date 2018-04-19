function [dataOut] = tsConvert(tIn,tOut,data,varargin)
% data -> [nt,nx]
% option -> 1 - mean, 2 - sum

option=1;
if ~isempty(varargin)
    option=varargin{1};
end

[nt,nx]=size(data);
if length(tIn)~=nt
    error('data and tIn size are not consistant')
end

tIn=VectorDim(tIn,1);
tOut=VectorDim(tOut,1);

tInD=floor(tIn);
[~,ind]=ismember(tInD,tOut);

dataOut=zeros(length(tOut),nx)*nan;
for k=1:length(tOut)
    temp=data(ind==k,:);
    if option==1
        tempOut=nanmean(temp,1);
    elseif option==2
        tempOut=nansum(temp,1);
    end
    dataOut(k,:)=tempOut;
end
    


end


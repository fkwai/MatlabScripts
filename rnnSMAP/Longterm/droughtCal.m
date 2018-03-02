function [outMat,dataT] = droughtCal( data,tnum )
% calculate drought percentil for given time window

% data - [nt, ncell]
% tnum - [nt, 1]

tD=tnum;
dataD=data;
nGrid=size(dataD,2);

%% convert to weekly
tDay=3;
tW=[tD(1)+tDay:tD(end)-tDay]';
dataW_All=zeros(length(tW),nGrid,tDay*2+1);
for k=1:tDay*2+1
    dataW_All(:,:,k)=dataD(k:end-tDay*2-1+k,:);
end
dataW=nanmean(dataW_All,3);

%% calculate percentile 
dataMat=dataW;
dataT=tW;

nt=size(dataMat,1);
nGrid=size(dataMat,2);
outMat=zeros(nt,nGrid)*nan;
tWindow=5;  %[t-tWindow, t+tWindow]

for iT=1:365            
    indT=iT:365:nt;
    indSd=iT-tWindow:365:nt-tWindow;
    indEd=iT+tWindow:365:nt+tWindow;
    indAll=[];
    indEx=[];
    for k=1:length(indSd)        
        indEx=[indEx,indSd(k):indT(k)-1,indT(k)+1:indEd(k)];
    end
    indEx(indEx<1)=[];
    indEx(indEx>nt)=[];
    
    dataTemp=dataMat([indT,indEx],:);
    ny=length(indT);
    nAll=sum(~isnan(dataTemp));
    [C,sMat]=sort(dataTemp);
    sMat(isnan(C))=nan;
    [~,iMat]=sort(sMat);
    outVec=iMat(1:ny)./repmat(nAll,[ny,1]);
    
    outMat(indT,:)=outVec;    
end



end


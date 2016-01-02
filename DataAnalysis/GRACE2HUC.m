function [ HUCstr ] = GRACE2HUC( HUCstr, graceGridFile,mask)
% Add GRACE to HUC without considering HUCstr_t

graceGridFile='E:\work\GRACE\graceGrid_CSR.mat';
maskFile='E:\work\DataAnaly\mask\mask_huc4_grace_global_32.mat';

graceGridData=load(graceGridFile);
graceGrid=graceGridData.graceGrid;
factorGrid=graceGridData.factorGrid;
t=graceGridData.t;
tm=str2num(datestr(t,'yyyymm'));
tmall=unique(str2num(datestr(t(1):t(end),'yyyymm')));
[C,idata,iall]=intersect(tm,tmall);
n=length(HUCstr);
for i=1:n
    masktemp=mask{i};
    temp=zeros(length(tmall),1)*nan;
    data=zeros(length(tm),1)*nan;    
    ind=find(masktemp>0);
    mm=masktemp(ind);
    for j=1:length(idata)        
        g=graceGrid(:,:,j);g=g(ind);
        ind2=find(~isnan(g));
        g=g(ind2);m=mm(ind2);
        data(j)=sum(g.*m)/sum(m);
    end
    f=factorGrid;f=f(ind);
    ind2=find(~isnan(f));
    f=f(ind2);m=mm(ind2);
    factor=sum(f.*m)/sum(m);
    
    temp(iall)=data(idata);
    HUCstr(i).GRACE=temp*10;
    HUCstr(i).GRACEt=datenum(num2str(tmall),'yyyymm');
    HUCstr(i).GRACE_factor=factor;
end
end


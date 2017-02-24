% according to Dr Shen, extract ts 6 cells in SMAPq and plot all ts and ts
% of mean
tic
SMAPq=load('Y:\SMAP\SMAP_L2_q.mat');
toc

lat=40.875;
lon=-77.875;
iyc=find(SMAPq.lat==lat);
ixc=find(SMAPq.lon==lon);
ix=[ixc+1,ixc,ixc,ixc-1,ixc-1,ixc-2];
iy=[iyc-1,iyc-1,iyc,iyc,iyc+1,iyc+1];
t=SMAPq.tnum;

vv=zeros(length(t),6);
for k=1:length(ix)    
    v=reshape(SMAPq.data(iy(k),ix(k),:),[length(t),1]);
    vv(:,k)=v;
    ind=find(~isnan(v));
    ts.v=v(ind);
    ts.t=t(ind);
    plot(ts.t,ts.v,getS(2+k,'l'),'lineWidth',1);hold on    
end
v=mean(vv,2);
ind=find(~isnan(v));
ts.v=v(ind);
ts.t=t(ind);
plot(ts.t,ts.v,'K','lineWidth',2);hold off
datetick('x','yyyymmdd');
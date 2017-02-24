folder='Y:\GRACE\ascii\';
[ data,t,x,y,factor ] = readGRACEtxt(  folder, 'CSR' );
save E:\Kuai\GRACE\grace_global_CSR data t x y factor

graceData=load('E:\Kuai\GRACE\grace_global_CSR.mat');
xx=graceData.x;
yy=graceData.y;
xx(xx>180)=xx(xx>180)-360;
graceGrid=data2grid3d(graceData.data,xx,yy,1);
graceGrid(abs(graceGrid)>1000)=nan;
factorGrid=data2grid3d(graceData.factor,xx,yy,1);
factorGrid(factorGrid==32767)=nan;
x=xx;y=yy;
t=graceData.t;
save E:\Kuai\GRACE\graceGrid_CSR.mat graceGrid factorGrid x y t

%add to HUCstr
HUCstr = initialHUCstr('Y:\DataAnaly\HUC\HUC4_main.shp','HUC4');
load('Y:\DataAnaly\mask\mask_HUC4.mat','maskGRACE')

crdGRACEfile='Y:\DataAnaly\crd\crd_GRACE_global.mat';
GRACE_file='Y:\GRACE\gracegrid_CSR.mat';
GRACEerr_file='Y:\GRACE\GRACE_ERR_grid.mat';
crdGRACE=load(crdGRACEfile);
GRACEdata=load(GRACE_file);
t=GRACEdata.t;
HUCstr_t=datenumMulti(unique(datenumMulti(t(1):t(end),3)),1);
HUCstr = grid2HUC_month('GRACE',GRACEdata.graceGrid*10,GRACEdata.t,maskGRACE,HUCstr,HUCstr_t);

save Y:\DataAnaly\BasinStr\HUCstr_GRACE.mat HUCstr HUCstr_t



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
    HUCstr(i).GRACE=temp;
    HUCstr(i).GRACEt= datenum(num2str(tmall),'yyyymm');
    HUCstr(i).GRACE_factor=factor;
end

ii=120;
ts1.v=HUCstr(ii).S;ts1.t=HUCstr_t;
ts2.v=HUCstr(ii).GRACE;ts2.t=HUCstr(ii).GRACEt;
plotTS(ts1,'-*');hold on;
plotTS(ts2,'r-*');hold off;

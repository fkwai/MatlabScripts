function postProc_figure(ind)

outfolder='Y:\Kuai\rnnSMAP\output\out_soilM\';
outfolder2='Y:\Kuai\rnnSMAP\output\out_nosoilM\';

yfolder='Y:\Kuai\rnnSMAP\tDB_SMPq\';
ysfolder='Y:\Kuai\rnnSMAP\tDB_soilM\';

gridInd=20000+ind;
nt=4160;
iterLst=[200:200:1200];
c=flipud(autumn(length(iterLst)));

%% read obs
y=zeros(nt,length(gridInd));
for i=1:length(gridInd)
    yfile=[yfolder,'data/',sprintf('%06d',gridInd(i)),'.csv'];
    y(:,i)=csvread(yfile);
end
y(y==-9999)=nan;
temp=csvread([yfolder,'stat.csv']);
lb=temp(1);ub=temp(2);

%% read soilM
ys=zeros(4160,length(gridInd));
for i=1:length(gridInd)
    yfile=[ysfolder,'data\',sprintf('%06d',gridInd(i)),'.csv'];
    ys(:,i)=csvread(yfile);
end
ys(ys==-9999)=nan;
ys=ys/100;
nash_ys=1-nansum((ys-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2);


%% read sim
figure('Position',[100,200,1800,400])
subplot(1,2,1)
title('with GLDAS soilM')
legendstr={};

for k=1:length(iterLst)
    iter=iterLst(k);
    outfile=[outfolder,'iter',num2str(iter),'.csv'];
    ypall=csvread(outfile);
    yp=ypall(:,ind);
    yp=(yp+1)*(ub-lb)/2+lb;
    nash=1-nansum((yp-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2);    
    plot(yp,'-','color',c(k,:));hold on
    legendstr=[legendstr,['iter',num2str(iter),' ',num2str(nash,'%.2f')]];
end
plot(y,'b*');hold on
plot(ys,'k');hold on
legendstr_GLDAS=['GLDAS',' ',num2str(nash_ys,'%.2f')];
legendstr=[legendstr,'SMAP',legendstr_GLDAS];
hold off
legend(legendstr,'Location','bestoutside')

%% read sim - no soil
subplot(1,2,2)
title('without GLDAS soilM')
legendstr={};
for k=1:length(iterLst)
    iter=iterLst(k);
    outfile=[outfolder2,'iter',num2str(iter),'.csv'];
    ypall=csvread(outfile);
    yp=ypall(:,ind);
    yp=(yp+1)*(ub-lb)/2+lb;
    nash=1-nansum((yp-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2);    
    plot(yp,'-','color',c(k,:));hold on
    legendstr=[legendstr,['iter',num2str(iter),' ',num2str(nash,'%.2f')]];
end
plot(y,'b*');hold on
plot(ys,'k');hold on
legendstr_GLDAS=['GLDAS',' ',num2str(nash_ys,'%.2f')];
legendstr=[legendstr,'SMAP',legendstr_GLDAS];
hold off
legend(legendstr,'Location','bestoutside')


end
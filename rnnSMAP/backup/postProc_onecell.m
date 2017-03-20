close all

yfolder='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
ysfolder='Y:\Kuai\rnnSMAP\Database\tDB_soilM\';
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
tnum=grid.tnum;

gridInd=20000;
outfolder=['Y:\Kuai\rnnSMAP\output\onecell\',num2str(gridInd,'%06d'),'b\'];

% outfolder=['Y:\Kuai\rnnSMAP\output\onecellAll\'];
% %outfolder=['Y:\Kuai\rnnSMAP\output\onecellTest\'];
% dirLst=dir(outfolder);
% fileLst={dirLst(3:end).name};
% r=randi([1,length(fileLst)],1,1);
% outfile=[outfolder,fileLst{r}];
% gridInd=str2num(fileLst{r}(1:6));
% close all

ntrain=2209;
nt=4160;


%% predefine
%iterLst=[20:20:200];
iterLst=[1000];

%% read obs
y=zeros(nt,length(gridInd));
for i=1:length(gridInd)
    yfile=[yfolder,'data/',sprintf('%06d',gridInd(i)),'.csv'];
    y(:,i)=csvread(yfile);
end
y(y==-9999)=nan;
temp=csvread([yfolder,'stat.csv']);
lb=temp(1);ub=temp(2);
y_train=y(1:ntrain);
y_test=y(ntrain+1:end);

%% read soilM
ys=zeros(4160,length(gridInd));
for i=1:length(gridInd)
    yfile=[ysfolder,'data\',sprintf('%06d',gridInd(i)),'.csv'];
    ys(:,i)=csvread(yfile);
end
ys(ys==-9999)=nan;
ys=ys/100;
ys_train=ys(1:ntrain);
ys_test=ys(ntrain+1:end);

%nash
nash_ys=1-nansum((ys-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2);
nash_ys_train=1-nansum((ys_train-y_train).^2)./nansum((y_train-repmat(nanmean(y_train),[ntrain,1])).^2);
nash_ys_test=1-nansum((ys_test-y_test).^2)./nansum((y_test-repmat(nanmean(y_test),[nt-ntrain,1])).^2);
nashTab(1,:)=[nash_ys,nash_ys_train,nash_ys_test];
%rmse
rmse_ys=sqrt(nanmean((ys-y).^2));
rmse_ys_train=sqrt(nanmean((ys_train-y_train).^2));
rmse_ys_test=sqrt(nanmean((ys_test-y_test).^2));
rmseTab(1,:)=[rmse_ys,rmse_ys,rmse_ys_test];



%% read sim
figure('Position',[100,300,1600,400])
%subplot(2,1,1)
legendstr={};
yrange=[-0.1,0.5];
c=flipud(autumn(length(iterLst)));
for k=1:length(iterLst)
    iter=iterLst(k);
    outfile=[outfolder,'iter',num2str(iter),'.csv'];
    %outfile=[outfolder,num2str(gridInd,'%06d'),'_iter',num2str(iter),'.csv'];
    yp=csvread(outfile);    
    yp=(yp+1)*(ub-lb)/2+lb;
    yp_train=yp(1:ntrain);
    yp_test=yp(ntrain+1:end);
    %nash
    nash=1-nansum((yp-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2);
    nash_train=1-nansum((yp_train-y_train).^2)./nansum((y_train-repmat(nanmean(y_train),[ntrain,1])).^2);
    nash_test=1-nansum((yp_test-y_test).^2)./nansum((y_test-repmat(nanmean(y_test),[nt-ntrain,1])).^2);
    %rmse
    rmse=sqrt(nanmean((yp-y).^2));
    rmse_train=sqrt(nanmean((yp_train-y_train).^2));
    rmse_test=sqrt(nanmean((yp_test-y_test).^2));
    %plot(tnum,yp,'-','color',c(k,:));hold on
    plot(tnum,yp,'.-b','LineWidth',1);hold on
    legendstr=[legendstr,['iter',num2str(iter),' ',num2str(nash,'%.2f')...
        ' ',num2str(nash_train,'%.2f'),' ',num2str(nash_test,'%.2f')]];
    nashTab(2,:)=[nash,nash_train,nash_test]
    rmseTab(2,:)=[rmse,rmse_train,rmse_test]
end
plot(tnum,y,'ro','LineWidth',2);hold on
plot(tnum,ys,'k','LineWidth',2);hold on
legendstr_GLDAS=['GLDAS',' ',num2str(nash_ys,'%.2f'),...
    ' ',num2str(nash_ys_train,'%.2f'),' ',num2str(nash_ys_test,'%.2f')];
legendstr=[legendstr,'SMAP',legendstr_GLDAS];
datetick('x','mmm');
title(['LSTM learning with GLDAS SoilM, grid: ',num2str(gridInd)])
xlabel('Time')
ylabel('Soil Moisture')
ylim(yrange);
plot([tnum(ntrain),tnum(ntrain)],yrange,'k','LineWidth',3)
hold off
%legend(legendstr,'Location','bestoutside')
legend('LSTM','SMAP','GLDAS','Location','bestoutside')


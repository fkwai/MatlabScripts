GRACEnormDir='E:\Kuai\rnnGRACE\data\gridTabGRACE_norm.csv';
GRACEDir='E:\Kuai\rnnGRACE\data\gridTabGRACE.csv';
GRACEnorm=csvread(GRACEnormDir);
GRACE=csvread(GRACEDir);

SErrnormDir='E:\Kuai\rnnGRACE\data\gridTabSErr_norm.csv';
SErrDir='E:\Kuai\rnnGRACE\data\gridTabSErr.csv';
SErrnorm=csvread(SErrnormDir);
SErr=csvread(SErrDir);

load('cont.mat')
load('ampGRACE.mat')
resultMat=[];

bs=100;
nit=1000;

for c=[1,2]
    for hs=[50,100]
        for out=[1,2]
            outfileTrain=['E:\Kuai\rnnGRACE\out\','GRACEout',num2str(out),'train_c',...
                num2str(c),'_bs',num2str(bs),'_hs',num2str(hs),'_nit',num2str(nit)];
            outfileTest=['E:\Kuai\rnnGRACE\out\','GRACEout',num2str(out),'test_c',...
                num2str(c),'_bs',num2str(bs),'_hs',num2str(hs),'_nit',num2str(nit)];
            dataTrain = csvread(outfileTrain);
            dataTest = csvread(outfileTest);
            %eval(['ydata=',tField{itF},';'])
            ydata=GRACEnorm;
            [C,lb,ub,y_mean]=normalize_perc(ydata,10);
            xTrain=(dataTrain'+1)./2.*(ub-lb)+lb+y_mean;
            xTest=(dataTest'+1)./2.*(ub-lb)+lb+y_mean;
            
            yTrain=ydata(cont~=c,1:96);
            yTest=ydata(cont==c,1:96);
            rmseTrain=sqrt(meanALL((yTrain-xTrain).^2));
            rmseTest=sqrt(meanALL((yTest-xTest).^2));
            
            result=[out-1,hs,c,rmseTrain,rmseTest]
            resultMat=[resultMat;result];
        end
    end
end

hs=50;
c=2;
out=1;
outfileTrain=['E:\Kuai\rnnGRACE\out\','GRACEout',num2str(out),'train_c',...
    num2str(c),'_bs',num2str(bs),'_hs',num2str(hs),'_nit',num2str(nit)];
outfileTest=['E:\Kuai\rnnGRACE\out\','GRACEout',num2str(out),'test_c',...
    num2str(c),'_bs',num2str(bs),'_hs',num2str(hs),'_nit',num2str(nit)];
dataTrain = csvread(outfileTrain);
dataTest = csvread(outfileTest);
%eval(['ydata=',tField{itF},';'])
ydata=GRACE;
[C,lb,ub,y_mean]=normalize_perc(ydata,10);
xTrain=(dataTrain'+1)./2.*(ub-lb)+lb+y_mean;
xTest=(dataTest'+1)./2.*(ub-lb)+lb+y_mean;
yTrain=ydata(cont~=c,1:96);
yTest=ydata(cont==c,1:96);

errTrain=sqrt((xTrain-yTrain).^2);
errTest=sqrt((xTest-yTest).^2);
errTrain_grid=sqrt(mean((xTrain-yTrain).^2,2))./ampGRACE(cont~=2);
errTest_grid=sqrt(mean((xTest-yTest).^2,2))./ampGRACE(cont==2);

figure('Position',[1,1,800,600])
histx=[0:0.1:5];
plot(histx,histc(errTest_grid,histx)./length(errTest_grid),'b','LineWidth',2);hold on
plot(histx,histc(errTrain_grid,histx)./length(errTrain_grid),'r','LineWidth',2);hold off
legend('Training','Test')
xlabel('RMSE / Amplitude')
title('Error Histogram of Training and Test set')
suffix = '.eps';
fixFigure([],['histErr',suffix]);
saveas(gcf, 'histErr');

figure('Position',[1,1,1200,500])
herr=histc(errTrain_grid,histx)./length(errTrain_grid);
plot([prctile(errTest_grid,25),prctile(errTest_grid,25)],[0,0.12],'k','LineWidth',2);hold on
plot([prctile(errTest_grid,50),prctile(errTest_grid,50)],[0,0.12],'k','LineWidth',2);hold on
plot([prctile(errTest_grid,75),prctile(errTest_grid,75)],[0,0.12],'k','LineWidth',2);hold on
plot(histx,histc(errTrain_grid,histx)./length(errTrain_grid),'r','LineWidth',2);hold off
xlabel('RMSE / Amplitude')
title('Error Histogram of Test set')
suffix = '.eps';
fixFigure([],['histErrTest',suffix]);
saveas(gcf, 'histErrTest');


for k=1:4    
    iTrain=randi([1,size(yTrain,1)]);
    iTest=randi([1,size(yTest,1)]);    
    t=1:96;
    
    subplot(4,2,k*2-1)
    ts1.t=t;ts1.v=yTrain(iTrain,:);
    ts2.t=t;ts2.v=xTrain(iTrain,:);
    plotTS(ts1,'r');hold on
    plotTS(ts2,'b');hold on    
    rmse=sqrt(mean((ts1.v-ts2.v).^2));    
    title(['Train: ind=',num2str(iTrain),'; rmse=',num2str(rmse)])
    legend('Target','Pred')
    
    subplot(4,2,k*2)
    ts1.t=t;ts1.v=yTest(iTest,:);
    ts2.t=t;ts2.v=xTest(iTest,:);
    plotTS(ts1,'r');hold on
    plotTS(ts2,'b');hold on    
    rmse=sqrt(mean((ts1.v-ts2.v).^2));    
    title(['Test: ind=',num2str(iTrain),'; rmse=',num2str(rmse)])
    legend('Target','Pred')
end



GRACE1d=reshape(GRACE,[144*14440,1]);
SErr1d=reshape(SErr,[144*14440,1]);
h1=histc(GRACE1d,[-20:20]);
plot([-20:20],h1)
h2=histc(SErr1d,[-800:10:200]);
plot([-800:10:200],h2)

%% plot
plotdir='E:\Kuai\rnnGRACE\figure\';
indMask=load('indMask.mat');

tm=unique(datenumMulti(datenumMulti(200210,1):datenumMulti(201009,1),3));
t=datenumMulti(tm,1);
hs=50;
c=2;
out=2;
bs=100;
nit=1000;
outfileTrain=['E:\Kuai\rnnGRACE\out\','GRACEout',num2str(out),'train_c',...
    num2str(c),'_bs',num2str(bs),'_hs',num2str(hs),'_nit',num2str(nit)];
outfileTest=['E:\Kuai\rnnGRACE\out\','GRACEout',num2str(out),'test_c',...
    num2str(c),'_bs',num2str(bs),'_hs',num2str(hs),'_nit',num2str(nit)];
ydata=GRACE;
dataTrain = csvread(outfileTrain);
dataTest = csvread(outfileTest);
[C,lb,ub,y_mean]=normalize_perc(ydata,10);
xTrain=(dataTrain'+1)./2.*(ub-lb)+lb+y_mean;
xTest=(dataTest'+1)./2.*(ub-lb)+lb+y_mean;
yTrain=ydata(cont~=c,1:96);
yTest=ydata(cont==c,1:96);

errTrain=sqrt((xTrain-yTrain).^2);
errTest=sqrt((xTest-yTest).^2);
errTrain_grid=sqrt(mean((xTrain-yTrain).^2,2));
errTest_grid=sqrt(mean((xTest-yTest).^2,2));

for perc=[25,50,75];
    perr1=prctile(errTest_grid,perc-2);
    perr2=prctile(errTest_grid,perc+2);
    indsel=find(errTest_grid>perr1 & errTest_grid<perr2);
    
    xland=indMask.xland(cont==c);
    yland=indMask.yland(cont==c);
    
    for k=1:20
        f=figure('Position', [100,100,800,600]);
        i=randi([1,length(indsel)]);
        ind=indsel(i);
        ts1.t=t;ts1.v=yTest(ind,:);
        ts2.t=t;ts2.v=xTest(ind,:);
        plotTS(ts1,'r');hold on
        plotTS(ts2,'b');hold off
        rmse=sqrt(mean((ts1.v-ts2.v).^2,2));
        lon=xland(ind);
        lat=yland(ind);
        title(['lon=',num2str(lon),' lat=',num2str(lat),'  RMSE=',num2str(rmse)])
        legend('GRACE','Prediction')
        xlabel('year')
        ylabel('GRACE TWS (cm)')
        
        fname=[plotdir,'perc',num2str(perc),'_',num2str(k)];
        suffix = '.eps';
        fixFigure([],[fname,suffix]);
        saveas(gcf, fname);
        close(f)
    end
end


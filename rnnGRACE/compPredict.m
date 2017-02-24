GRACEnormDir='E:\Kuai\rnnGRACE\data\gridTabGRACE_norm.csv';
GRACEDir='E:\Kuai\rnnGRACE\data\gridTabGRACE.csv';
GRACEnorm=csvread(GRACEnormDir);
GRACE=csvread(GRACEDir);
[C,lb,ub]=normalize_perc( GRACE,10);

bs=100;
hs=100;
lr=0.01;

outfile1=['E:\Kuai\rnnGRACE\out\GRACEout1_bs100_hs100_nit1000'];
outfile2=['E:\Kuai\rnnGRACE\out\GRACEout2_bs100_hs100_nit1000'];
data1 = csvread(outfile1);
data2 = csvread(outfile2);
data_range = csvread([outfile1,'_range']);
ind1=data_range(1,1);
ind2=data_range(1,2);
step1=data_range(2,1);
step2=data_range(2,2);

x1=(data1'+1)./2.*(ub-lb)+lb;
x2=(data2'+1)./2.*(ub-lb)+lb;
y=GRACE(ind1:ind2,step1:step2);

err1=sqrt((x1-y).^2);
err2=sqrt((x2-y).^2);
errMean1=mean(err1,2);
errMean2=mean(err2,2);
[S,I]=sort(errMean2);

for k=1:8
    subplot(4,2,k)
    %i=randi([ind1,ind2]);
    i=I(k+16);
    t=step1:step2;
    ts1.t=t;ts1.v=y(i,:);
    ts2.t=t;ts2.v=x1(i,:);
    ts3.t=t;ts3.v=x2(i,:);
    plotTS(ts1,'r');hold on
    plotTS(ts2,'b');hold on
    plotTS(ts3,'g');hold off
    rmse1=sqrt(mean((x1(i,:)-y(i,:)).^2));
    rmse2=sqrt(mean((x2(i,:)-y(i,:)).^2));
    title(['ind=',num2str(i),'; rmse=',num2str(rmse1),' ',num2str(rmse2)])
end


for mon=1:96
err1=sqrt((x1(:,mon)-y(:,mon)).^2);
err2=sqrt((x2(:,mon)-y(:,mon)).^2);
errM1(mon)=meanALL(err1);
errM2(mon)=meanALL(err2);
end
errM1=errM1';errM2=errM2';
plot(errM1,'b');hold on
plot(errM2,'r');hold off

map1=rnnPred2map(x1);
map2=rnnPred2map(x2);
mapGRACE=rnnPred2map(y);

mon=30;
subplot(2,1,1);imagesc(map1(:,:,mon),[-20,20])
axis equal;xlim([0,360]);colorbar
title('LSTM prediction')
subplot(2,1,2);imagesc(mapGRACE(:,:,mon),[-20,20])
axis equal;xlim([0,360]);colorbar
title('GRACE observation')


lon=-179.5:179.5;
lat=[89.5:-1:-59.5]';
[f,range] = showGlobalMap( map1(:,:,mon),lon,lat,1,'pred','LSTM prediction',[-20,20],'cm/month' );
[f,range] = showGlobalMap( mapGRACE(:,:,mon),lon,lat,1,'grace','GRACE observation',[-20,20],'cm/month' );


load('Y:\GRACE\GRACE_ERR_grid.mat')
measure_Err(151:180,:)=[];
measure_Err(abs(measure_Err)>100)=nan;

mapDiff=map1-mapGRACE;
subplot(2,1,1);imagesc(abs(mapDiff(:,:,mon)),[0,20])
axis equal;xlim([0,360]);colorbar
title('Absolute Difference between prediction and observation')
subplot(2,1,2);imagesc(abs(measure_Err),[0,10])
axis equal;xlim([0,360]);colorbar
title('GRACE Measurement Error')

lon=-179.5:179.5;
lat=[89.5:-1:-59.5]';
[f,range] = showGlobalMap( mapDiff(:,:,mon),lon,lat,1,'prederr','Prediction Error',[0,20],'cm/month' );
[f,range] = showGlobalMap(measure_Err,lon,lat,1,'measureerr','GRACE Measurement Error',[0,10],'cm/month' );









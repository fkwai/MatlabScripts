
% figFolder='H:\Kuai\rnnSMAP\paper\';
% unitStr='[-]';
% suffix = '.jpg';
% 
% %% pick points
% global kPath
% outName='CONUSs4f1_new';
% trainName='CONUSs4f1';
% testName='CONUSs4f1';
% epoch=500;
% 
% [outTrain,outTest,covMethod]=testRnnSMAP_readData(outName,trainName,testName,epoch);
% statTrain_LSTM=statCal(outTrain.yLSTM,outTrain.ySMAP);
% statTest_LSTM=statCal(outTest.yLSTM,outTest.ySMAP);
% statTrain_NLDAS=statCal(outTrain.yGLDAS,outTrain.ySMAP);
% statTest_NLDAS=statCal(outTest.yGLDAS,outTest.ySMAP);
% 
% crd=csvread([kPath.DBSMAP_L3,testName,'\crd.csv']);
% [rmseOrd,indOrd]=sort(statTest_LSTM.rmse);
% indSelOrd=[40,100,200,300,362];
% textStr={'%10','%25','%50','%75','%90'};

%% plot
f=figure('Position',[1,1,1600,800]);
for k=1:5
    sf=subplot(3,2,k);
    row=ceil(k/2);
    col=2-rem(k,2);
    ind=indSelOrd(k);
    tnum=datenumMulti(20150401):datenumMulti(20170401);
    v1=[outTrain.ySMAP(:,ind);outTest.ySMAP(:,ind)];
    v2=[outTrain.yLSTM(:,ind);outTest.yLSTM(:,ind)];
    v3=[outTrain.yGLDAS(:,ind);outTest.yGLDAS(:,ind)];
    
    plot([tnum(367),tnum(367)],[0,1],'--k','LineWidth',2);hold on
    plot(tnum,v1,'or','LineWidth',2);hold on
    plot(tnum,v2,'b-','LineWidth',2);hold on
    plot(tnum,v3,'k-','LineWidth',2);hold off
    if col==1
        set(gca,'XTick',[datenum(2015,[4:3:12]',1);datenum(2016,[1:3:12]',1);datenum(2017,[1:3:4]',1)]);
    elseif col==2
        set(gca,'XTick',[datenum(2015,[7:3:12]',1);datenum(2016,[1:3:12]',1);datenum(2017,[1:3:4]',1)]);
    end
    datetick('x','mm/yy','keepticks')   
    maxY=max([v1;v2;v3]);
    minY=min([v1;v2;v3]);
    ylim([max(0,minY),maxY+0.05])
    xlim([tnum(1),tnum(end)])
    
    px0=0.05+0.48*(col-1);
    py0=0.1+(3-row)*0.3;
    width=0.45;
    heigth=0.25;
    set(gca,'Position',[px0,py0,width,heigth])
    text(tnum(1)+20,maxY,textStr{k},'fontSize',16,'EdgeColor','k','Margin',6)
end

subplot(3,2,6)
row=3;
col=2;
px0=+0.48*(col-1)+0.15;
py0=0.05+(3-row)*0.3;
width=0.32;
heigth=0.28;
set(gca,'Position',[px0,py0,width,heigth])

legItem=[];
legItem(1)=plot([0,0],[1,1],'ro','LineWidth',2);hold on
legItem(2)=plot([0,0],[1,1],'-b','LineWidth',2);hold on
legItem(3)=plot([0,0],[1,1],'-k','LineWidth',2);hold on
shape=shaperead('H:\Kuai\map\USA.shp');
for kk=1:length(shape)
    plot(shape(kk).X,shape(kk).Y,'b');hold on
end
for k=1:5
    ind=indSelOrd(k);
    plot(crd(ind,2),crd(ind,1),'r*','LineWidth',2);hold on
    text(crd(ind,2),crd(ind,1)-2,textStr{k},'fontSize',14);hold on
end
xlim([-125,-66])
ylim([25,50]);
axis equal

set(gca,'xTick',[],'yTick',[])
hold off
leg=legend(legItem,'SMAP','LSTM','Noah');
set(leg,'Position',[px0-0.09,py0+0.05,0.08,0.15]);

fname=[figFolder,'\','timeSeries'];
fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);

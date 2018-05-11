
global kPath
rootOut=kPath.OutSigma_L3_NA;
rootDB=kPath.DBSMAP_L3_NA;
dataName='CONUSv4f1';
epoch=500;

strLstC1={'1d2','3','5'};
strLstC2={'0d05','0d15','0d3'};

saveFolder='/mnt/sdc/Kuai/rnnSMAP_result/sigma/';

%% start
[ySMAP1,ySMAP_stat,crd,t1]=readDB_Global(dataName,'SMAP_AM','yrLst',2015,'rootDB',rootDB);
[ySMAP2,~,~,t2]=readDB_Global(dataName,'SMAP_AM','yrLst',2016:2017,'rootDB',rootDB);
yLSTM1_org=readRnnPred('CONUSv4f1_2015',dataName,epoch,[2015,2015],...
    'rootOut',kPath.OutSMAP_L3_NA,'rootDB',rootDB);
yLSTM2_org=readRnnPred('CONUSv4f1_2015',dataName,epoch,[2016,2017],...
    'rootOut',kPath.OutSMAP_L3_NA,'rootDB',rootDB);

statStr='rmse';
statMat={};
labelY={};
stat1=statCal(yLSTM1_org,ySMAP1);
stat2=statCal(yLSTM2_org,ySMAP2);
statMat=[statMat;{stat1.(statStr),stat2.(statStr)}];
labelY=[labelY;{'no sigma'}];

k=0;
sigmaMat=struct('strC1','','strC2','','yLSTM1',[],'yLSTM2',[],...
    'ySigma1',[],'ySigma2',[],'sig1',[],'sig2',[]);
fDist=figure('Position',[1,1,1200,800]);

%% iter to plot map / save data for plot
for i1=1:length(strLstC1)
    for i2=1:length(strLstC2)
        k=k+1;
        %% read sigma prediction
        strC1=strLstC1{i1};
        strC2=strLstC2{i2};
        C1=str2double(strrep(strC1,'d','.'));
        C2=str2double(strrep(strC2,'d','.'));
        outName=[dataName,'_',strC1,'_',strC2];
        epoch=500;
        [yLSTM1,ySigma1]=readRnnPred_sigma(outName,dataName,epoch,[2015,2015],...
            'rootOut',rootOut,'rootDB',rootDB);
        [yLSTM2,ySigma2]=readRnnPred_sigma(outName,dataName,epoch,[2016,2017],...
            'rootOut',rootOut,'rootDB',rootDB);
        
        %% box plot data - performance of soil moisture pred
        stat1=statCal(yLSTM1,ySMAP1);
        stat2=statCal(yLSTM2,ySMAP2);
        statMat=[statMat;{stat1.(statStr),stat2.(statStr)}];
        labelY=[labelY;{[strC1,',',strC2]}];
        
        %% sigma map
        sig1=sqrt(exp(ySigma1))*ySMAP_stat(4)^2;
        sig2=sqrt(exp(ySigma2))*ySMAP_stat(4)^2;
        [gridSig,xx,yy] = data2grid3d(sig2',crd(:,2),crd(:,1));
        [gridRmse,~,~] = data2grid(stat2.rmse',crd(:,2),crd(:,1));
        fmap=showMap(mean(gridSig,3),yy,xx,'strTitle',['test sigma c1=',num2str(C1),',c2=',num2str(C1)]);
        saveas(fmap,[saveFolder,'sigmaMap',strC1,'_',strC2,'.png'])
        fmap=showMap(gridRmse,yy,xx,'strTitle',['test RMSE c1=',num2str(C1),',c2=',num2str(C1)]);
        saveas(fmap,[saveFolder,'rmseMap',strC1,'_',strC2,'.png'])
        
        %% distribution of sigma
        alpha=C1-1;
        beta=C2/2*ySMAP_stat(4);
        sigSq1=sig1(:);
        sigSq2=sig2(:);
        [yHist1,xHist1] = histcounts(sigSq1,100);
        dx1=nanmean(xHist1(2:end)-xHist1(1:end-1));
        xDist1=(xHist1(1:end-1)+xHist1(2:end))/2;
        yDist1=yHist1./length(sigSq1)./dx1;
        [yHist2,xHist2] = histcounts(sigSq2,100);
        dx2=nanmean(xHist2(2:end)-xHist2(1:end-1));
        xDist2=(xHist2(1:end-1)+xHist2(2:end))/2;
        yDist2=yHist2./length(sigSq2)./dx2;
        
        sigMax=max([sigSq1;sigSq2]);
        xDist=linspace(0,sigMax,100);
        %xDistSq=xDist.^2;
        yDist=beta^alpha/gamma(alpha)*xDist.^(-alpha-1).*exp(-beta./xDist);
        figure(fDist);
        subplot(length(strLstC1),length(strLstC2),k)
        plot(xDist,yDist,'k');hold on
        plot(xDist1,yDist1,'b');hold on
        plot(xDist2,yDist2,'r');hold off
        legend('ref PDF','train','test')
        xlabel('sigma sq')
        title(['c1=',num2str(C1),'; ','c2=',num2str(C2)])
        
        %% save data
        sigmaMat(k)=struct('strC1',strC1,'strC2',strC2,'yLSTM1',yLSTM1,'yLSTM2',yLSTM2,...
            'ySigma1',ySigma1,'ySigma2',ySigma2,'sig1',sig1,'sig2',sig2);
        
    end
end
save([saveFolder,'sigmaMat.mat'],'sigmaMat','ySMAP1','ySMAP2',...
    'yLSTM1_org','yLSTM2_org','ySMAP_stat')

%% box plot for rmse
f=plotBoxSMAP(statMat,{'train','test'},labelY,'yRange',[0,0.08]);
saveas(f,[saveFolder,'soilmBox.png'])





figFolder='H:\Kuai\rnnSMAP\paper\';
suffix = '.eps';
global fsize
fsize=16

%% load temporal data
global kPath
outName='CONUSs4f1_surf';
outName2='CONUSs4f1_noModel';
trainName='CONUSs4f1';
testNameT='CONUSs4f1';
epoch=500;

[outTrainT,outT,covT]=testRnnSMAP_readData(outName,trainName,testNameT,epoch,'varLst','varLst_NOAH');
[outTrainT2,outT2,covT]=testRnnSMAP_readData(outName2,trainName,testNameT,epoch,'varLst','varLst_noModel');

statSel=statCal(outT.yLSTM,outT.ySMAP);
ind=find(statSel.rmse<0.1);

statTtrain_LSTM=statCal(outTrainT.yLSTM,outTrainT.ySMAP);
statT_LSTM=statCal(outT.yLSTM(:,ind),outT.ySMAP(:,ind));
statT2_LSTM=statCal(outT2.yLSTM(:,ind),outT2.ySMAP(:,ind));

statTtrain_NLDAS=statCal(outTrainT.yGLDAS,outTrainT.ySMAP);
statT_NLDAS=statCal(outT.yGLDAS(:,ind),outT.ySMAP(:,ind));
statT2_NLDAS=statCal(outT2.yGLDAS(:,ind),outT2.ySMAP(:,ind));

statTtrain_LR=statCal(outTrainT.yLR,outTrainT.ySMAP);
statT_LR=statCal(outT.yLR(:,ind),outT.ySMAP(:,ind));
statT2_LR=statCal(outT2.yLR(:,ind),outT2.ySMAP(:,ind));

statTtrain_NN=statCal(outTrainT.yNN,outTrainT.ySMAP);
statT_NN=statCal(outT.yNN(:,ind),outT.ySMAP(:,ind));
statT2_NN=statCal(outT2.yNN(:,ind),outT2.ySMAP(:,ind));

statTtrain_LRpbp=statCal(outTrainT.yLRpbp,outTrainT.ySMAP);
statT_LRpbp=statCal(outT.yLRpbp(:,ind),outT.ySMAP(:,ind));
statT2_LRpbp=statCal(outT2.yLRpbp(:,ind),outT2.ySMAP(:,ind));

statTtrain_NNpbp=statCal(outTrainT.yNNpbp,outTrainT.ySMAP);
statT_NNpbp=statCal(outT.yNNpbp(:,ind),outT.ySMAP(:,ind));
statT2_NNpbp=statCal(outT2.yNNpbp(:,ind),outT2.ySMAP(:,ind));


%% load spatial data
outName='CONUSs4f1_surf';
outName2='CONUSs4f1_noModel';
trainName='CONUSs4f1';
testNameS='CONUSs4f2';
epoch=500;

[outTrainS,outS,covS]=testRnnSMAP_readData(outName,trainName,testNameS,epoch,'timeOpt',3,'varLst','varLst_NOAH');
[outTrainS2,outS2,covS2]=testRnnSMAP_readData(outName2,trainName,testNameS,epoch,'timeOpt',3,'varLst','varLst_noModel');

statSel=statCal(outS.yLSTM,outS.ySMAP);
ind=find(statSel.rmse<0.1);

statStrain_LSTM=statCal(outTrainS.yLSTM,outTrainS.ySMAP);
statS_LSTM=statCal(outS.yLSTM(:,ind),outS.ySMAP(:,ind));
statS2_LSTM=statCal(outS2.yLSTM(:,ind),outS2.ySMAP(:,ind));

statStrain_NLDAS=statCal(outTrainS.yGLDAS,outTrainS.ySMAP);
statS_NLDAS=statCal(outS.yGLDAS(:,ind),outS.ySMAP(:,ind));
statS2_NLDAS=statCal(outS2.yGLDAS(:,ind),outS2.ySMAP(:,ind));

statStrain_LR=statCal(outTrainS.yLR,outTrainS.ySMAP);
statS_LR=statCal(outS.yLR(:,ind),outS.ySMAP(:,ind));
statS2_LR=statCal(outS2.yLR(:,ind),outS2.ySMAP(:,ind));

statStrain_NN=statCal(outTrainS.yNN,outTrainS.ySMAP);
statS_NN=statCal(outS.yNN(:,ind),outS.ySMAP(:,ind));
statS2_NN=statCal(outS2.yNN(:,ind),outS2.ySMAP(:,ind));


%% plot
figure('Position',[1,1,1000,1200])
statLst={'rmse','bias','rsq'};
subLst={'(a)','(b)','(c)','(d)','(e)','(f)'};
for k=1:length(statLst)
    stat=statLst{k};
    switch stat
        case 'rmse'
            yRangeT=[0,0.1];
            yRangeS=[0,0.1];
            yLabelStr='RMSE';
        case 'bias'
            yRangeT=[-0.05,0.05];
            yRangeS=[-0.05,0.05];
            yLabelStr='Bias';
        case 'rsq'
            yRangeT=[0,1];
            yRangeS=[0,1];
            yLabelStr='R^2';
    end
    
    %% plot temporal
    nTrain=length(statTtrain_LSTM.(stat));
    nT=length(statT_LSTM.(stat));
    dataLst=[statTtrain_LSTM.(stat);statT_LSTM.(stat);statT2_LSTM.(stat);...
        statTtrain_NN.(stat);statT_NN.(stat);statT2_NN.(stat);...
        statTtrain_LR.(stat);statT_LR.(stat);statT2_LR.(stat);...
        statTtrain_NNpbp.(stat);statT_NNpbp.(stat);statT2_NNpbp.(stat);...
        statTtrain_LRpbp.(stat);statT_LRpbp.(stat);statT2_LRpbp.(stat);...
        statTtrain_NLDAS.(stat);statT_NLDAS.(stat);statT2_NLDAS.(stat);];
    
    labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);repmat({'noModel'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);repmat({'noModel'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);repmat({'noModel'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);repmat({'noModel'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);repmat({'noModel'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);repmat({'noModel'},nT,1);];
    labelLst2=[repmat({'LSTM'},nTrain+nT*2,1);...
        repmat({'NN'},nTrain+nT*2,1);...
        repmat({'LR'},nTrain+nT*2,1);...
        repmat({'NNp'},nTrain+nT*2,1);...
        repmat({'LRp'},nTrain+nT*2,1);...
        repmat({'Noah'},nTrain+nT*2,1);];
    
    subplot(3,2,(k-1)*2+1)
    bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rkb','Symbol','+','Widths',0.75);
    ylabel(yLabelStr);
    xlabel(subLst{(k-1)*2+1})
    ylim(yRangeT)
    
    xRange=get(gca,'xlim');
    nBin=6;
    binWidth=(xRange(2)-xRange(1))/nBin;
    xTick=(xRange(1)+binWidth/2):binWidth:(xRange(2)-binWidth/2);    
    set(gca,'xtick',xTick,'ytick',yRangeT(1):(yRangeT(2)-yRangeT(1))/5:yRangeT(2))
    set(gca,'xticklabel',{'LSTM','NN','LR','NNp','LRp','Noah'})
    set(bh,'LineWidth',2)
    box_vars = findall(gca,'Tag','Box');
    %     if strcmp(stat,'rsq')
    %         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northeast');
    %     else
    %         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
    %     end
    if k==1
        hLegend = legend(box_vars([3,2,1]), {'Train','Test w/ Noah','Test w/o Noah'},...
            'location','northwest','Orientation','horizontal');
        hLegend.Orientation = 'horizontal';
    end
        if strcmp(stat,'bias')
            hline=refline([0,0]);
            set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
        end
    if strcmp(stat,'rmse')
        title(['Temporal Generalization Test'])
    end
    set(gca,'Position',[0.1,0.1+(3-k)*0.3,0.45,0.25])
    
    %% plot spatial
    nTrain=length(statStrain_LSTM.(stat));
    nS=length(statS_LSTM.(stat));
    dataLst=[statStrain_LSTM.(stat);statS_LSTM.(stat);statS2_LSTM.(stat);...
        statStrain_NN.(stat);statS_NN.(stat);statS2_NN.(stat);...
        statStrain_LR.(stat);statS_LR.(stat);statS2_LR.(stat);...
        statStrain_NLDAS.(stat);statS_NLDAS.(stat);statS2_NLDAS.(stat);];
    
    labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);repmat({'noModel'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);repmat({'noModel'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);repmat({'noModel'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);repmat({'noModel'},nS,1);];
    labelLst2=[repmat({'LSTM'},nTrain+nS*2,1);...
        repmat({'NN'},nTrain+nS*2,1);...
        repmat({'LR'},nTrain+nS*2,1);...
        repmat({'Noah'},nTrain+nS*2,1);];
    
    subplot(3,2,(k-1)*2+2)
    bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rkb','Symbol','+','Widths',0.75);
    %ylabel(yLabelStr);
    xlabel(subLst{(k-1)*2+2})
    ylim(yRangeS)
    
    xRange=get(gca,'xlim');
    nBin=4;
    binWidth=(xRange(2)-xRange(1))/nBin;
    xTick=(xRange(1)+binWidth/2):binWidth:(xRange(2)-binWidth/2); 
    set(bh,'LineWidth',2)
    set(gca,'xtick',xTick,'ytick',yRangeT(1):(yRangeT(2)-yRangeT(1))/5:yRangeT(2))
    set(gca,'xticklabel',{'LSTM','NN','LR','Noah'});
    box_vars = findall(gca,'Tag','Box');
%     if strcmp(stat,'rsq')
%         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northeast');
%     else
%         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
%     end
    if strcmp(stat,'bias')
        hline=refline([0,0]);
        set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
    end
    if strcmp(stat,'rmse')
        title(['Regular Spatial Generalization Test'])
    end
    set(gca,'Position',[0.65,0.1+(3-k)*0.3,0.275,0.25])
end

fname=[figFolder,'\','boxplot_noModel_surf_All'];
fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);




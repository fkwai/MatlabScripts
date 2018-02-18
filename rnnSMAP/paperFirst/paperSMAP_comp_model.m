% compare LSTM training result between MOS and Noah

figFolder='H:\Kuai\rnnSMAP\paper\';
fname=[figFolder,'\','boxplot_Noah_MOS'];
suffix = '.eps';
global fsize
fsize=16

%% load data
% temporal
global kPath
trainName='CONUSv4f1';
testNameT='CONUSv4f1';
epoch=500;

outName='CONUSv4f1_MOS';
modelName='MOS';
[outTrainT_MOS,outT_MOS,covT_MOS]=testRnnSMAP_readData(outName,trainName,testNameT,epoch,...
    'readData',0,'model',modelName);

statTtrain_LSTM_MOS=statCal(outTrainT_MOS.yLSTM,outTrainT_MOS.ySMAP);
statT_LSTM_MOS=statCal(outT_MOS.yLSTM,outT_MOS.ySMAP);
statTtrain_NLDAS_MOS=statCal(outTrainT_MOS.yGLDAS,outTrainT_MOS.ySMAP);
statT_NLDAS_MOS=statCal(outT_MOS.yGLDAS,outT_MOS.ySMAP);

outName='CONUSv4f1';
modelName='Noah';
[outTrainT,outT,covT]=testRnnSMAP_readData(outName,trainName,testNameT,epoch,...
    'readData',0,'model',modelName);

statTtrain_LSTM=statCal(outTrainT.yLSTM,outTrainT.ySMAP);
statT_LSTM=statCal(outT.yLSTM,outT.ySMAP);
statTtrain_NLDAS=statCal(outTrainT.yGLDAS,outTrainT.ySMAP);
statT_NLDAS=statCal(outT.yGLDAS,outT.ySMAP);

%% spatial
trainName='CONUSv4f1';
testNameS='CONUSv4f2';
epoch=500;

outName='CONUSv4f1_MOS';
modelName='MOS';
[outTrainS_MOS,outS_MOS,covS_MOS]=testRnnSMAP_readData(outName,trainName,testNameS,epoch,...
    'timeOpt',3,'readData',0,'model',modelName);

statStrain_LSTM_MOS=statCal(outTrainS_MOS.yLSTM,outTrainS_MOS.ySMAP);
statS_LSTM_MOS=statCal(outS_MOS.yLSTM,outS_MOS.ySMAP);
statStrain_NLDAS_MOS=statCal(outTrainS_MOS.yGLDAS,outTrainS_MOS.ySMAP);
statS_NLDAS_MOS=statCal(outS_MOS.yGLDAS,outS_MOS.ySMAP);

outName='CONUSv4f1';
modelName='Noah';
[outTrainS,outS,covS]=testRnnSMAP_readData(outName,trainName,testNameS,epoch,...
    'timeOpt',3,'readData',0,'model',modelName);

statStrain_LSTM=statCal(outTrainS.yLSTM,outTrainS.ySMAP);
statS_LSTM=statCal(outS.yLSTM,outS.ySMAP);
statStrain_NLDAS=statCal(outTrainS.yGLDAS,outTrainS.ySMAP);
statS_NLDAS=statCal(outS.yGLDAS,outS.ySMAP);


%% plot
figure('Position',[1,1,1000,1000])
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
            yRangeT=[0.4,1];
            yRangeS=[0.4,1];
            yLabelStr='R';
    end
    
    %% plot temporal
    nTrain=length(statTtrain_LSTM.(stat));
    nT=length(statT_LSTM.(stat));
    dataLst=[statTtrain_LSTM.(stat);statT_LSTM.(stat);...
        statTtrain_LSTM_MOS.(stat);statT_LSTM_MOS.(stat);...        
        statTtrain_NLDAS.(stat);statT_NLDAS.(stat);...
        statTtrain_NLDAS_MOS.(stat);statT_NLDAS_MOS.(stat);];    
    labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);];
    labelLst2=[repmat({'LSTM-Noah'},nTrain+nT,1);...
        repmat({'LSTM-MOS'},nTrain+nT,1);...
        repmat({'Noah'},nTrain+nT,1);...
        repmat({'Mos'},nTrain+nT,1);];
    
    subplot(3,2,(k-1)*2+1)
    bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rk','Symbol','','Widths',0.75);
    ylabel(yLabelStr);
    h1 = xlabel(subLst{(k-1)*2+1});    
    ylim(yRangeT)
    xLimit=get(gca,'xlim');
    nBin=length(unique(labelLst2));
    xTick=linspace(xLimit(1),xLimit(2),2*nBin+1);
    set(gca,'xtick',xTick(2:2:end),'ytick',yRangeT(1):(yRangeT(2)-yRangeT(1))/5:yRangeT(2))
    set(gca,'xticklabel',{'L+Noah','L+MOS','Noah','MOS'});
    set(bh,'LineWidth',2)
    box_vars = findall(gca,'Tag','Box');
    if k==1
        hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
    end    
    if strcmp(stat,'bias')
        hline=refline([0,0]);
        set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
    end
    if strcmp(stat,'rmse')
        title(['Temporal Generalization Test'])
    end
    set(gca,'Position',[0.1,0.1+(3-k)*0.3,0.35,0.24])
    Pos= get(h1,'Position'); Pos(2)=-25; set(h1,'Position',Pos); 

    
    %% plot spatial
    nTrain=length(statStrain_LSTM.(stat));
    nS=length(statS_LSTM.(stat));
    
    dataLst=[statStrain_LSTM.(stat);statS_LSTM.(stat);...
        statStrain_LSTM_MOS.(stat);statS_LSTM_MOS.(stat);...        
        statStrain_NLDAS.(stat);statS_NLDAS.(stat);...
        statStrain_NLDAS_MOS.(stat);statS_NLDAS_MOS.(stat);];    
    labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);];
    labelLst2=[repmat({'LSTM-Noah'},nTrain+nS,1);...
        repmat({'LSTM-MOS'},nTrain+nS,1);...
        repmat({'Noah'},nTrain+nS,1);...
        repmat({'Mos'},nTrain+nS,1);];    

    
    subplot(3,2,(k-1)*2+2)
    bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rk','Symbol','','Widths',0.75);
    %ylabel(yLabelStr);
    h1=xlabel(subLst{(k-1)*2+2});
    ylim(yRangeS)
    set(bh,'LineWidth',2)
    xLimit=get(gca,'xlim');
    nBin=length(unique(labelLst2));
    xTick=linspace(xLimit(1),xLimit(2),2*nBin+1);
    set(gca,'xtick',xTick(2:2:end),'ytick',yRangeT(1):(yRangeT(2)-yRangeT(1))/5:yRangeT(2))
    set(gca,'xticklabel',{'L+Noah','L+MOS','Noah','MOS'});
    box_vars = findall(gca,'Tag','Box');
    if strcmp(stat,'bias')
        hline=refline([0,0]);
        set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
    end
    if strcmp(stat,'rmse')
        title(['Regular Spatial Generalization Test'])
    end
    set(gca,'Position',[0.55,0.1+(3-k)*0.3,0.35,0.24])
    Pos= get(h1,'Position'); Pos(2)=-25; set(h1,'Position',Pos); 

end

fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);




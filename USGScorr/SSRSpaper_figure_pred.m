% plot predictors and low / medium / high correlation

% mB
figfolder='E:\Kuai\SSRS\paper\mB\';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
datafile='E:\Kuai\SSRS\data\dataset_mB_4949.mat';
predind=[0,2,4,9,22,31,45,50]+1;
global fsize


%% figure 3c - Predictors_boxplot_cluster
load(datafile);
load(usgsCorrMatfile)
field(predind+1)
np=length(predind);
fsize=18
fieldstr={'Drainage Area (sqkm)','Prcp (cm/year)','Relative Humidity (%)',...
    'Snow/P','Forest (%)','Silt Cont (%)', '\gamma','Sim Index'};

corrAvg=zeros(size(usgsCorr,1),6);
for i=1:6
    temp=mean(usgsCorr(:,(i-1)*5+1:i*5),2);
    corrAvg(:,i)=temp;
end
corrMax=corrAvg(:,1:3);
corrMin=corrAvg(:,4:6);

corr=corrMax;
sup='max';

figure('Position',[1,1,1500,800])
for i=1:np
    ind=randi([1,size(corr,1)],[100,1]);
    subplot(ceil(np/2),4,i);
    x=dataset(:,predind(i));
    plot(x(ind),corr(ind,1)','r.');hold on
    plot(x(ind),corr(ind,2)','g.');hold on
    plot(x(ind),corr(ind,3)','b.');hold off
    %legend('Low Flow','Medium Flow','High Flow')
    xlabel(fieldstr{i})
end

suffix = '.eps';
fname=[figfolder,'Predictors_corr_',sup];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);



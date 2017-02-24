% year=14
% if year==14
%     figfolder='E:\Kuai\SSRS\paper\14\';
%     usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
%     shapefile='E:\Kuai\SSRS\data\gages_14_4881.shp';
%     divfile='E:\Kuai\SSRS\data\division_14_4881.mat';
%     datafile='E:\Kuai\SSRS\data\dataset_14_4881.mat';
%     pydistfile='E:\Kuai\SSRS\data\py_dist_14_4881';
%     pypcafile='E:\Kuai\SSRS\data\py_pca_14_4881';
%     pypregfile='E:\Kuai\SSRS\data\py_reg_14_4818.mat';
%     predind=[45, 46, 9, 4, 50, 26, 48, 31, 11, 2]+1;
%     global fsize
% elseif year==12
%     figfolder='E:\Kuai\SSRS\paper\12\';
%     usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_12_4919.mat';
%     shapefile='E:\Kuai\SSRS\data\gages_12_4919.shp';
%     divfile='E:\Kuai\SSRS\data\division_12_4919.mat';
%     datafile='E:\Kuai\SSRS\data\dataset_12_4919.mat';
%     pydistfile='E:\Kuai\SSRS\data\py_dist_12_4919';
%     pypcafile='E:\Kuai\SSRS\data\py_pca_12_4919';
%     predind=[44, 45, 8, 39, 3, 49, 24, 26]+1;
%     global fsize
% end
% mB
figfolder='E:\Kuai\SSRS\paper\mB\';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
divfile='E:\Kuai\SSRS\data\division_mB_4949.mat';
datafile='E:\Kuai\SSRS\data\dataset_mB_4949.mat';
pydistfile='E:\Kuai\SSRS\data\py_dist_mB_4949';
pypcafile='E:\Kuai\SSRS\data\py_pca_mB_4949';
pypregfile='E:\Kuai\SSRS\data\py_reg_mB_4949.mat';
predind=[46, 11, 8, 50, 41, 2, 22, 29]+1;
global fsize

%% regression result
regMat=load(pypregfile);
figure('Position',[1,1,1200,1080])
fsize=14;
for i=1:6
    subplot(3,2,i);
    x1=regMat.Y_train(:,i);
    y1=regMat.Yptrain(:,i);
    x2=regMat.Y_test(:,i);
    y2=regMat.Yp(:,i);
    
    plot(x1,y1,'*b');hold on
    plot(x2,y2,'.r');hold on
    plot121Line
    
    ymax=max([max(regMat.Yptrain(:,i)),max(regMat.Yptrain(:,i)),...
        max(regMat.Y_test(:,i)),max(regMat.Yp(:,i))]);
    ymax=ceil(ymax);
    
    rmse_train=sqrt(mean((x1-y1).^2));
    rmse_test=sqrt(mean((x2-y2).^2));
    cc_train=corrcoef(x1,y1);cc_train=cc_train(1,2);
    cc_test=corrcoef(x2,y2);cc_test=cc_test(1,2);
    
    row=ceil(i/2);
    col=rem(i,2);
    
    title({['#',num2str(i-1)],...
        ['Train: CorrCoef=',num2str(cc_train,2),'; RMSE=',num2str(rmse_train,2),],...
        ['Test: CorrCoef=',num2str(cc_test,2),'; RMSE=',num2str(rmse_test,2),]})
    if row==3
        xlabel('Truth Distance')
    end
    if col==1
        ylabel('Predict Distance')
    end
    if i~=6
        %leg=legend('Train','Test','Location','northwest');
    else
        leg=legend('Train','Test','Location','southeast');
        %set(leg,'Position',[0.9,0.8,0.08,0.05]);
    end
    %axis equal    
    xlim([0,ymax]);
    ylim([0,ymax]);
end

suffix = '.eps';
fname=[figfolder,'regResult'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
% pydistfile='E:\Kuai\SSRS\data\py_dist_14_4881';
% treematfile='E:\Kuai\SSRS\data\py_tree_14_4818.mat';
% treematfile_train='E:\Kuai\SSRS\data\py_tree_train_14_4818.mat';
% treematfile_test='E:\Kuai\SSRS\data\py_tree_test_14_4818.mat';
% regmatfile='E:\Kuai\SSRS\data\py_reg_14_4818.mat';
% usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
% shapefile='E:\Kuai\SSRS\data\gages_14_4881.shp';
% treefigfolder='E:\Kuai\SSRS\paper\14\treemap\';

pydistfile='E:\Kuai\SSRS\data\py_dist_mB_4949.mat';
treematfile='E:\Kuai\SSRS\data\py_tree_mB_4949.mat';
treematfile_train='E:\Kuai\SSRS\data\py_tree_train_mB_4949.mat';
treematfile_test='E:\Kuai\SSRS\data\py_tree_test_mB_4949.mat';
regmatfile='E:\Kuai\SSRS\data\py_reg_mB_4949.mat';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
treefigfolder='E:\Kuai\SSRS\paper\mB\treemap\';

%load(usgsCorrMatfile')
distMat=load(pydistfile);
treeMat=load(treematfile);
treeMat_train=load(treematfile_train);
treeMat_test=load(treematfile_test);
regMat=load(regmatfile);
shape=shaperead(shapefile);
shpUSA=shaperead('Y:\Maps\USA.shp');

rmse_test=sqrt(mean((regMat.Yp-regMat.Y_test).^2,2));
rmse_train=sqrt(mean((regMat.Yptrain-regMat.Y_train).^2,2));
rmse=zeros(length(distMat.indvalid),1);
rmse(regMat.ind_train+1)=rmse_train;
rmse(regMat.ind_test+1)=rmse_test;
% IDshape=cellfun(@str2num,{shape.STAID})';
% unique(ID-IDshape)
X=[shape(distMat.indvalid+1).X];
Y=[shape(distMat.indvalid+1).Y];

%% map of nodes
f=figure('Position',[1,1,1500,1080]);

for i=1:length(treeMat.nodeind)   
    i
    f=figure('Position',[1,1,1000,1080]);
    ind=treeMat.nodeind{i}+1;
    ind_train=treeMat_train.ind_train(treeMat_train.nodeind{i}+1)+1;
    ind_test=treeMat_test.ind_test(treeMat_test.nodeind{i}+1)+1;    
    colormap(flipud(jet))
    
    subplot(2,1,1)
    scatter(X(ind_train),Y(ind_train),[],rmse(ind_train));hold on   
    h=colorbar;
    fixColorAxis(h,[0,1],5,'rmse')
    xlim([-130,-65])
    ylim([25,50])
    title(['Train: leaf ',num2str(i-1),' # gage ',num2str(length(ind_train))])
    axis equal
    for j=1:length(shpUSA)
        plot(shpUSA(j).X,shpUSA(j).Y,'--k')
    end
    hold off
    
    subplot(2,1,2)
    scatter(X(ind_test),Y(ind_test),[],rmse(ind_test));hold on   
    h=colorbar;
    fixColorAxis(h,[0,1],5,'rmse')
    xlim([-130,-65])
    ylim([25,50])
    title(['Test: leaf ',num2str(i-1),' # gage ',num2str(length(ind_test))])
    axis equal
    for j=1:length(shpUSA)
        plot(shpUSA(j).X,shpUSA(j).Y,'--k')
    end
    hold off
    
    fname=[treefigfolder,'node',num2str(i-1),'_map.png'];
    saveas(gcf, fname);
    fname=[treefigfolder,'node',num2str(i-1),'_map'];
    saveas(gcf, fname);
    
    close(f)
end


%% PA
outFolder='Y:\Kuai\rnnSMAP\output\PA\';
trainName='PA';
testName='PA';
epoch=2000; 
shapefile='Y:\Maps\State\PA.shp';
stat='nash';% or rmse, rsq, bias
colorRange=[-1,1];
opt=1; %0->all; 1->train; 2->test
testRnnSMAP_map(outFolder,trainName,testName,epoch,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%% OK
outFolder='Y:\Kuai\rnnSMAP\output\OK\';
trainName='OK';
testName='OK';
epoch=600;
shapefile='Y:\Maps\State\OK.shp';
stat='nash';% or rmse, rsq, bias
colorRange=[-1,1];
opt=1; %0->all; 1->train; 2->test
testRnnSMAP_map(outFolder,trainName,testName,epoch,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%% US sub 16
outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
trainName='indUSsub4';
testName='indUSsub4';
epoch=16000;
shapefile='Y:\Maps\USA.shp';
stat='nash';% or rmse, rsq, bias
colorRange=[-0.8,0.8];
opt=1; %0->all; 1->train; 2->test
[statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,epoch,'doAnorm',1);
testRnnSMAP_map(outFolder,trainName,testName,epoch,'doAnorm',1,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);
%% test
outFolder='Y:\Kuai\rnnSMAP\output\test_CONUS\';
trainName='indUSSub4';
testName='indUSSub4';
epoch=800;
shapefile='Y:\Maps\USA.shp';
colorRange=[-0.8,0.8];
opt=1;
stat='nash';% or rmse, rsq, bias
[statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,epoch,'doAnorm',1);
%testRnnSMAP_ts(outFolder,trainName,testName,100);
testRnnSMAP_map(outFolder,trainName,testName,epoch,'doAnorm',1,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%% US sub 4 - onecell
outFolder='Y:\Kuai\rnnSMAP\output\onecell_NA\';
trainName='indUSsub4';
testName='indUSsub4';
epoch=7000;
shapefile='Y:\Maps\USA.shp';
stat='nash';% or rmse, rsq, bias
colorRange=[-1,1];
opt=1; %0->all; 1->train; 2->test
testRnnSMAP_map(outFolder,trainName,testName,epoch,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%% regional
outFolder='Y:\Kuai\rnnSMAP\output\CONUS_div\';
epoch=500;
n=7;
for i=1:n
    for j=1:n
        i
        j
        trainName=['div_sub4_',num2str(i)];
        testName=['div_sub4_',num2str(j)];
        [statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,epoch,'doAnorm',1);
    end
end

% combine to leave-one-out test
for i=1:n
    trainNameLst={};
    testNameLst={};
    for j=1:n
        if i~=j
            trainNameLst=[trainNameLst;['div_sub4_',num2str(i)]];
            testNameLst=[testNameLst;['div_sub4_',num2str(j)]];
        end
    end
    trainNameComb=['div_sub4_',num2str(i)];
    testNameComb=['div_sub4_N',num2str(i)];
    combineRegion_SMAP( outFolder,trainNameLst,testNameLst,trainNameComb,testNameComb,epoch,0)
end

% plot for leave-one-out test
for k=1:n
    trainName=['div_sub4_',num2str(k)];
    testName=['div_sub4_N',num2str(k)];
    [statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,epoch,'doAnorm',1);
end

% no extropolation
outFolder='Y:\Kuai\rnnSMAP\output\CONUS_lulc\';
epoch=500;
n=9;
trainNameLst={};
testNameLst={};
for k=1:n
    trainName=['lulc_sub4_',num2str(k)];
    testName=['lulc_sub4_',num2str(k)];
    trainNameLst=[trainNameLst;trainName];
    testNameLst=[testNameLst;testName];        
    [statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,epoch,'doAnorm',1);
end
trainNameComb='lulc_sub4_comb';
testNameComb='lulc_sub4_comb';
combineRegion_SMAP( outFolder,trainNameLst,testNameLst,trainNameComb,testNameComb,epoch,0)
testRnnSMAP_plot(outFolder,trainNameComb,testNameComb,epoch,'doAnorm',1);




outFolder='Y:\Kuai\rnnSMAP\output\CONUS_NDVI\';
trainName='ndvi_sub4_combo';
testName='ndvi_sub4_combo';
epoch=500;
[statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,epoch,'doAnorm',1);

i=5
stat='nash';% or rmse, rsq, bias
trainName=['div_sub4_',num2str(i)];
testName=['div_sub4_',num2str(i)];
shapefile='Y:\Maps\USA.shp';
colorRange=[-0.8,0.8];
testRnnSMAP_map(outFolder,trainName,testName,epoch,'doAnorm',1,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%% test
outFolder='Y:\Kuai\rnnSMAP\output\test_CONUS\';
trainName='indUSsub4';
testName='indUSsub4';
epoch=800;
shapefile='Y:\Maps\USA.shp';
colorRange=[-0.8,0.8];
opt=1;
stat='nash';% or rmse, rsq, bias
[statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,epoch,'doAnorm',1);
%testRnnSMAP_ts(outFolder,trainName,testName,100);
testRnnSMAP_map(outFolder,trainName,testName,epoch,'doAnorm',1,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);
    opt=1;

function treeMatUpdate( fileName,predSel, saveFile )
% Update old tree matfile into new version

%% example
% fileName='Y:\Kuai\SSRS\trees\tree#102_0';
% load('E:\Kuai\SSRS\data\py_predList_mB_4949.mat')
% predSel=predListTest{102};
% saveFile='E:\Kuai\SSRS\paper\mB\tree#102_0.mat';
% treeMatUpdate( fileName,predSel, saveFile )

%%
matFile=[fileName,'.mat'];
regFile=[fileName,'_reg.mat'];
trainFile=[fileName,'_train.mat'];
testFile=[fileName,'_test.mat'];

matOld=load(matFile);
matReg=load(regFile);
matTrain=load(trainFile);
matTest=load(testFile);

%matOld.nodeind -> wrong in python. But training and test are fine
for i=1:length(matOld.nodeind)
    indTrain=matTrain.ind_train(matTrain.nodeind{i}+1);
    indTest=matTest.ind_test(matTest.nodeind{i}+1);
    nodeind{i}=sort([indTrain,indTest]);
end
ind_train=matTrain.ind_train;
ind_test=matTest.ind_test;
Yp=matReg.Yp;
Y_test=matReg.Y_test;
Yptrain=matReg.Yptrain;
Y_train=matReg.Y_train;
fieldInd=matOld.fieldInd;
predSel=predSel;
nodeValue=matOld.nodeValue;
nodeind_train=matTrain.nodeind;
nodeind_test=matTest.nodeind;
cleft=matOld.cleft;
cright=matOld.cright;
the=matOld.the;
indValid=matOld.indvalid;

save(saveFile,'nodeind','ind_train','ind_test','Yp','Y_test','Yptrain',...
    'Y_train','fieldInd','predSel','nodeValue','nodeind_train','nodeind_test',...
    'cleft','cright','the','indValid');



end


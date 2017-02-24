function combineRegion_SMAP( rootFolder,trainNameLst,testNameLst,trainNameComb,testNameComb,epoch,varargin )
% combine regional runing in SMAP RNN training. 
% for example, combine div_sub4_1_500, div_sub4_2_500,... to
% div_sub4_combo_500
% (Y:\Kuai\rnnSMAP\output\CONUS_div)

% this code need to be run after all regressions are done!

% varargin{1}: doSolo -> default to be zero. If trainNameLst and
% testNameLst are same, we probably did solo LR and ANN, then combine them
% as well.

% example:
% rootFolder='Y:\Kuai\rnnSMAP\output\CONUS_div\';
% epoch=500;
% trainNameLst={};
% testNameLst={};
% for k=2:7
%     trainNameLst=[trainNameLst;'div_sub4_1'];
%     testNameLst=[testNameLst;['div_sub4_',num2str(k)]];    
% end

disp('combining SMAP regions')

doSolo=0;
if ~isempty(varargin)
    doSolo=varargin{1};
end

nRegion=length(trainNameLst); 

data=[];
yLR=[];
yNN=[];
indCombo=[];
if doSolo
    yNNsolo=[];
    yLRsolo=[];
end

for k=1:nRegion
    fileInd=[rootFolder,testNameLst{k},'.csv'];
    ind=csvread(fileInd);
    indCombo=[indCombo;ind];
    
    fileLSTM=[rootFolder,'out_',trainNameLst{k},'_',...
        testNameLst{k},'_',num2str(epoch),'\data.mat'];
    matLSTM=load(fileLSTM);
    data=[data,matLSTM.data];
    
    fileLR=[rootFolder,'outLR_',trainNameLst{k},'_',testNameLst{k}];
    matLR=load(fileLR);
    yLR=[yLR,matLR.yLR];
    
    fileNN=[rootFolder,'outNN_',trainNameLst{k},'_',testNameLst{k}];
    matNN=load(fileNN);
    yNN=[yNN,matNN.yNN];
    
    if doSolo
        fileLRsolo=[rootFolder,'outLRsolo_',trainNameLst{k},'_',testNameLst{k}];
        matLRsolo=load(fileLRsolo);
        yLRsolo=[yLRsolo,matLRsolo.yLRsolo];
        
        fileNNsolo=[rootFolder,'outNNsolo_',trainNameLst{k},'_',testNameLst{k}];
        matNNsolo=load(fileNNsolo);
        yNNsolo=[yNNsolo,matNNsolo.yNNsolo];
    end
end

dlmwrite([rootFolder,testNameComb,'.csv'],indCombo,'precision',8); 

outFolder=[rootFolder,'out_',trainNameComb,'_',testNameComb,'_',num2str(epoch),'\'];
mkdir(outFolder);
save([outFolder,'data.mat'],'data')
save([rootFolder,'outLR_',trainNameComb,'_',testNameComb],'yLR')
save([rootFolder,'outNN_',trainNameComb,'_',testNameComb],'yNN')

if doSolo
    save([rootFolder,'outLRsolo_',trainNameComb,'_',testNameComb],'yLRsolo')
    save([rootFolder,'outNNsolo_',trainNameComb,'_',testNameComb],'yNNsolo')
end

end


jobHead = 'z';
D = dir([jobHead,'*']); 
hS = zeros(size(D))+128;
nGPU = 3; nConc = 6;

myCluster = parcluster('local');
dirJ = [cd,'\MPT\',jobHead]; if ~exist(dirJ),mkdir(dirJ); end
myCluster.JobStorageLocation = dirJ;
if ~ispc
    try
        parpool(myCluster,nConc);
    catch
        p = gcp('nocreate');
        delete(gcp('nocreate'))
        parpool(myCluster,nConc);
    end
else
    clc
end

temporalTest = 2;
if temporalTest==1
    trainTimeOpt = 1;
    testTimeOpt = 2;
else
    trainTimeOpt = 1;
    testTimeOpt = 1;
end

for i=1:length(D)
    trainCMD = 'CUDA_VISIBLE_DEVICES=0 th trainLSTM_SMAP.lua --out XX_out --train CONUS --dr 0.5 -timeOpt 1 --hiddenSize 384 --var varLst_Noah --varC varConstLst_Noah';
    trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
    trainCMD = strrep(trainCMD, '384', num2str(hS(i)));
    ID = mod(i-1,nGPU); wd = ['=',num2str(ID)];
    trainCMD = strrep(trainCMD, '=0', wd);
    trainCMD = strrep(trainCMD, '-timeOpt 1', ['-timeOpt ',num2str(trainTimeOpt)]);
    
    od = [D(i).name,'_hS',num2str(hS(i))];
    trainCMD = strrep(trainCMD, 'XX_out', od);
    % maybe hS need to be adjusted?
    if ispc
        disp(trainCMD)
    else
        system(trainCMD)
    end
        
    ID = mod(i-1,nGPU);
    trainCMD = 'CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 0 -out fullCONUS_hS384dr04 -epoch 500 -test CONUS -timeOpt 2';
    trainCMD = strrep(trainCMD, '=0', ['=',num2str(ID)]);
    trainCMD = strrep(trainCMD, 'fullCONUS_hS384dr04', [od]);
    trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
    trainCMD = strrep(trainCMD, '-timeOpt 2', ['-timeOpt ',num2str(testTimeOpt)]);
    
    if ispc
        disp(trainCMD)
    else
        system(trainCMD)
    end
end



function batchJobs(jobHead, nGPU, nConc, hs,temporalTest, varFile)

%{
jobHead = 'hlr';
nGPU = 2; nConc = 4;
hs=128;
temporalTest = 2; 
varFile = 'varLst_Noah';
batchJobs(jobHead, nGPU, nConc, hs, temporalTest, varFile)
%}
diary('batchJobsLog.log')
if ispc
    rt =cd;
else
    rt = '/mnt/sdd/rnnSMAP/Database_SMAPgrid/Daily/';
end

D = dir([rt,filesep,jobHead,'*']); 
hS = zeros(size(D))+hs;
testRun  = 1;


if ~testRun
     myCluster = parcluster('local');
    dirJ = [cd,filesep,'MPT',filesep,jobHead]; if ~exist(dirJ),mkdir(dirJ); end
    myCluster.JobStorageLocation = dirJ;
       
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

if temporalTest==1
    trainTimeOpt = 1;
    testTimeOpt = 2;
else
    trainTimeOpt = 1;
    testTimeOpt = 1;
end

for i=1:length(D)
    %    tic
    trainCMD = 'CUDA_VISIBLE_DEVICES=0 th trainLSTM_SMAP.lua -out XX_out -train CONUS -dr 0.5 -timeOpt 1 -hiddenSize 384 -var varLst_Noah -varC varConstLst_Noah';
    trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
    trainCMD = strrep(trainCMD, '384', num2str(hS(i)));
    ID = mod(i-1,nGPU); wd = ['=',num2str(ID)];
    trainCMD = strrep(trainCMD, '=0', wd);
    trainCMD = strrep(trainCMD, '-timeOpt 1', ['-timeOpt ',num2str(trainTimeOpt)]);
    trainCMD = strrep(trainCMD, 'varLst_Noah', varFile);
    
    od = [D(i).name,'_hS',num2str(hS(i)),'_',varFile];
    trainCMD = strrep(trainCMD, 'XX_out', od);
    % maybe hS need to be adjusted?
    runCmdInScript(trainCMD,jobHead,i)
        
    ID = mod(i-1,nGPU);
    trainCMD = 'CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_hS384dr04 -epoch 500 -test CONUS -timeOpt 2';
    trainCMD = strrep(trainCMD, '=0', ['=',num2str(ID)]);
    trainCMD = strrep(trainCMD, 'fullCONUS_hS384dr04', [od]);
    %trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
    trainCMD = strrep(trainCMD, '-timeOpt 2', ['-timeOpt ',num2str(testTimeOpt)]);
    
    runCmdInScript(trainCMD,jobHead,i)
%     if ispc || testRun
%         disp(trainCMD)
%     else
%          disp(trainCMD); tic
%          system('. ~/.bashrc')
%         system(trainCMD)
%         %t2=toc; disp(['Testing done. Elapsed time = ',num2str(t2)])
%     end
    % toc
end


function runCmdInScript(cmd,jobHead,i)
sD = [cd,filesep,'scripts',filesep];
if ~exist(sD)
    mkdir(sD)
end
sF = [jobHead,'_',num2str(i),'.sh'];
file = [sD,sF];

fid = fopen(file,'wt');
fprintf(fid,'%s\n','. ~/.bashrc');
fprintf(fid,'%s\n','export LD_LIBRARY_PATH=/home/kxf227/torch/install/lib'); 
% Above is what is causing problems with a simple Matlab launch
fprintf(fid,'%s\n',cmd);
fclose(fid);
trainCMD = ['. ',file];
if ispc || testRun
    disp('*******************************************')
    disp('runCmdInScript:: cmd to be submitted to OS:')
    disp(trainCMD)
    type(file)
else
    disp(trainCMD); %tic
    system(trainCMD)
    %t1=toc; disp(['Testing done. Elapsed time = ',num2str(t1)])
end


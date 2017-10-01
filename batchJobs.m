function batchJobs(res,prob,varargin)

%{
nGPU =3; nMultiple=4; jobHead='hlr'; epoch=300; hs=128; temporalTest=2;
% above are things to adjust. also consider 'varFile' below

%rt  = '/mnt/sdd/rnnSMAP/Database_SMAPgrid/Daily/';
rt = ''; % empty if using default settings on each machine
action = [1 2];
res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);

batchJobs(res,prob,[1 2]) % action contains 1: train; contains 2: test
%}
diary('batchJobsLog.log')

nGPU = res.nGPU; nConc = res.nGPU; 
jobHead = prob.jobHead; hs = prob.hs; temporalTest = prob.temporalTest; varFile = prob.varFile;
epoch = prob.epoch;

[s,hostname] = system('hostname');
if isfield(res,'rt') && ~isempty(res.rt)
    rt = res.rt;
else
    if ispc
        rt ='H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily';
    elseif strcmp(hostname,'CE-406SACKXF227')
        rt = '/mnt/sdd/rnnSMAP/Database_SMAPgrid/Daily/';
    end
end
action =[1 2]; % train and test
if length(varargin)>0
    action = varargin{1};
end

D = dir([rt,filesep,jobHead,'*']); 
hS = zeros(size(D))+hs;
testRun  = 1; % inside sub-function


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
    trainCMD = 'CUDA_VISIBLE_DEVICES=0 th trainLSTM_SMAP.lua -out XX_out -train CONUS -nEpoch 500 -dr 0.5 -timeOpt 1 -hiddenSize 384 -var varLst_Noah -varC varConstLst_Noah';
    trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
    trainCMD = strrep(trainCMD, '384', num2str(hS(i)));
    ID = mod(i-1,nGPU); wd = ['=',num2str(ID)];
    trainCMD = strrep(trainCMD, '=0', wd);
    trainCMD = strrep(trainCMD, '-timeOpt 1', ['-timeOpt ',num2str(trainTimeOpt)]);
    trainCMD = strrep(trainCMD, 'varLst_Noah', varFile);
    trainCMD = strrep(trainCMD, '500', num2str(epoch));
    
    od = [D(i).name,'_hS',num2str(hS(i)),'_VF',varFile];
    trainCMD = strrep(trainCMD, 'XX_out', od);
    % maybe hS need to be adjusted?
    if any(action==1)
        runCmdInScript(trainCMD,jobHead,i,1,testRun)
    end
        
    ID = mod(i-1,nGPU);
    trainCMD = 'CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_hS384dr04 -epoch 500 -test CONUS -timeOpt 2';
    trainCMD = strrep(trainCMD, '=0', ['=',num2str(ID)]);
    trainCMD = strrep(trainCMD, 'fullCONUS_hS384dr04', [od]);
    %trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
    trainCMD = strrep(trainCMD, '500', num2str(epoch));
    trainCMD = strrep(trainCMD, '-timeOpt 2', ['-timeOpt ',num2str(testTimeOpt)]);
    
    if any(action==2)
        runCmdInScript(trainCMD,jobHead,i,2,testRun)
    end
end


function runCmdInScript(cmd,jobHead,i,act,testRun)
%testRun = 0;
verb = 1;
sD = [cd,filesep,'scripts',filesep];
if ~exist(sD)
    mkdir(sD)
end
sF = [jobHead,'_',num2str(i),'_a',num2str(act),'.sh'];
file = [sD,sF];

fid = fopen(file,'wt');
fprintf(fid,'%s\n','. ~/.bashrc');
fprintf(fid,'%s\n','export LD_LIBRARY_PATH=/home/kxf227/torch/install/lib'); 
% Above is what is causing problems with a simple Matlab launch
fprintf(fid,'%s\n',cmd);
fclose(fid);
trainCMD = ['. ',file];
if ispc || testRun
    if verb>1
        disp('*******************************************')
        disp('runCmdInScript:: cmd to be submitted to OS:')
    end
    disp(trainCMD)
    if verb>1 type(file); end
else
    if verb>1, disp(trainCMD); end;tic
    system(trainCMD)
    t1=toc; 
    if verb>1, disp(['Testing done. Elapsed time = ',num2str(t1)]); end
end


function runBatchJob(res,optLst,action,varargin)
% run batch jobs of trainLSTM_SMAP and testLSTM_SMAP using MATLAB

%% input
% res - descriptions about batchs of jobs and how to allocate them in
% multiple GPUs.
% res.nGPU -
% res.nConc -

% optLst - list of options to run LSTM code
% optLst(n) has same options as LSTM code. See initRnnOpt.m

% action - 1 for training; 2 for testing

% varargin{1} - batchName, name for print files of this script
% varargin{2} - testRun, testRun=1 will write shell script but not run them.

%% example

%%
if ~isempty(varargin)
    batchName = varargin{1};
end
if length(varargin)>1
    testRun = varargin{2};
end

diary('batchJobsLog.log')
disp(['Number of Jobs=',num2str(length(optLst))]);

nGPU = res.nGPU; nConc = res.nConc;
nMultiple = nConc/nGPU;

if ~testRun
    myCluster = parcluster('local');
    dirJ = [cd,filesep,'MPT',filesep,batchName];
    if ~exist(dirJ)
        mkdir(dirJ);
    end
    myCluster.JobStorageLocation = dirJ;
    myCluster.NumWorkers = max(nConc,myCluster.NumWorkers);
    
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

fid = fopen('allJobs.sh','wt');
for i=1:nGPU
    for j=1:nMultiple
        ff=['JOB',jobHead,'_g',num2str(i-1),'_c',num2str(j)];
        CFILE{i,j} = [ff,'.sh'];
        %if exist(CFILE{i,j}), mode='at'; else, mode='wt'; end
        %CID(i,j)= fopen(CFILE{i,j},mode);
        fprintf(fid,'%s\n',['. ',CFILE{i,j},' > ',ff,'.log &']);
    end
end
fclose(fid); CA=zeros([nGPU,1]); nk=0;nD=length(D);





function runCmdInScript(cmd,jobHead,i,act,testRun,cid)
%testRun = 0;
% two files: a script file is for each individual job, to be used by Matlab
% parfor
% a global file is to generate job a per-GPU script to be run manually
% this is only generated on pc.
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
fprintf(fid,'%s\r\n',cmd);
fclose(fid);

if verb>2
    suffix = '';
else
    suffix = ' >/dev/null'; % standard device for discarding screen output
    % lua already has output logs in each directory
end
trainCMD = ['. ',file,suffix];
if ispc || testRun
    if verb>1
        disp('*******************************************')
        disp('runCmdInScript:: cmd to be submitted to OS:')
    end
    fprintf(cid,'%s\n',cmd);
    %disp(trainCMD)
    disp(cmd)
    if verb>1 type(file); end
else
    if verb>0, disp(cmd); end;tic;
    system(trainCMD)
    t1=toc;
    if verb>0, disp(['Elapsed time = ',num2str(t1),' for job: ',trainCMD]); end
    %delete(file);
end


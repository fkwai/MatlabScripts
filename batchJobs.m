function batchJobs(res,prob,varargin)

%{
nGPU =3; nMultiple=4; jobHead='hlr'; epoch=300; hs=128; temporalTest=2;
% above are things to adjust. also consider 'varFile' below
% by default all test are done on CONUS.

%rt  = '/mnt/sdd/rnnSMAP/Database_SMAPgrid/Daily/';
rt = ''; % empty if using default settings on each machine
action = [1 2];
res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);

batchJobs(res,prob,[1 2]) % action contains 1: train; contains 2: test
%}
diary('batchJobsLog.log')

nGPU = res.nGPU; nConc = res.nConc; 
jobHead = prob.jobHead; hs = prob.hs; temporalTest = prob.temporalTest; varFile = prob.varFile;
epoch = prob.epoch; if isfield(prob,'varCFile'),varCFile = prob.varCFile; else, varCFile='varConstLst_Noah';  end
if isfield(prob,'namePadd'), namePadd = prob.namePadd; else, namePadd=''; end
testRun  = 1; % inside sub-function--> may get over-written by varargin{2} (4-th input)
% testRun == 1: just print out statement. ==0, and change for i=1:length(D)
% to parfor: will run jobs through parfor

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
if length(varargin)>1
    testRun = varargin{2};
end

D = dir([rt,filesep,jobHead,'*']); 
hS = zeros(size(D))+hs;


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
if iscell(varFile) % a list of parameter files)
    VFILE=varFile;
else 
    VFILE{1}=varFile;
end

if iscell(varCFile) % a list of parameter files)
    VCFILE=varCFile;
else 
    VCFILE{1}=varCFile;
end
nMultiple = nConc/nGPU;
fid = fopen('allJobs.sh','wt');
for i=1:nGPU
    for j=1:nMultiple
        ff=['JOB',jobHead,'_g',num2str(i-1),'_c',num2str(j)];
        CFILE{i,j} = [ff,'.sh'];
        if exist(CFILE{i,j}), mode='at'; else, mode='wt'; end
        CID(i,j)= fopen(CFILE{i,j},mode);
        fprintf(fid,'%s\n',['. ',CFILE{i,j},' > ',ff,'.log &']);
    end
end
fclose(fid); CA=zeros([nGPU,1]); nk=0;
for m=1:length(VCFILE)
    varCFile = VCFILE{m};
    for k=1:length(VFILE)
        varFile = VFILE{k};
        for i=1:length(D)
            %    tic
            if D(i).isdir
                trainCMD = 'CUDA_VISIBLE_DEVICES=0 th trainLSTM_SMAP.lua -out XX_out -train CONUS -dr 0.5 -timeOpt 1 -hiddenSize 384 -var varLst_Noah -varC varConstLst_Noah -nEpoch 500';
                trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
                trainCMD = strrep(trainCMD, '384', num2str(hS(i)));
                
                %nk = i-1+(length(VFILE)-1)*length(D);
                nk = nk+1; % job id in the sequence
                ID = mod(nk,nGPU); wd = ['=',num2str(ID)]; CA(ID+1)=CA(ID+1)+1; % ID is GPU iD
                j = mod(CA(ID+1)-1,nMultiple)+1; % j is concurrent job id
                trainCMD = strrep(trainCMD, '=0', wd);
                trainCMD = strrep(trainCMD, '-timeOpt 1', ['-timeOpt ',num2str(trainTimeOpt)]);
                trainCMD = strrep(trainCMD, 'varLst_Noah', varFile);
                trainCMD = strrep(trainCMD, 'varConstLst_Noah', varCFile);
                trainCMD = strrep(trainCMD, '500', num2str(epoch));
                
                od = [D(i).name,namePadd,'_',varFile,'_',varCFile]; % output folder name. must be unique
                trainCMD = strrep(trainCMD, 'XX_out', od);
                if any(action==1)
                    runCmdInScript(trainCMD,jobHead,i,1,testRun,CID(ID+1,j));
                end
                
                ID = mod(i-1,nGPU);
                trainCMD = 'CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_hS384dr04 -epoch 500 -test CONUSv2f1 -timeOpt 2';
                trainCMD = strrep(trainCMD, '=0', ['=',num2str(ID)]);
                trainCMD = strrep(trainCMD, 'fullCONUS_hS384dr04', [od]);
                %trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
                trainCMD = strrep(trainCMD, '500', num2str(epoch));
                trainCMD = strrep(trainCMD, '-timeOpt 2', ['-timeOpt ',num2str(testTimeOpt)]);
                
                if any(action==2)
                    runCmdInScript(trainCMD,jobHead,i,2,testRun,CID(ID+1,j));
                end
            end
        end
    end
end

for i=1:numel(CID)
    fclose(CID(i));
end

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
trainCMD = ['. ',file];
if ispc || testRun
    if verb>1
        disp('*******************************************')
        disp('runCmdInScript:: cmd to be submitted to OS:')
    end
    fprintf(cid,'%s\n',cmd);
    disp(trainCMD)
    if verb>1 type(file); end
else
    if verb>1, disp(trainCMD); end;tic
    system(trainCMD)
    t1=toc; 
    if verb>1, disp(['Testing done. Elapsed time = ',num2str(t1)]); end
end

function caseScripts
% these codes are not used inside batchJobs.m.
% they are scripts to be used outside
% I save them here so we don't lose these notes
c=1;
switch c
    case 1
        % some scripts for used cases:
        nGPU =3; nMultiple=4; jobHead='huc2'; epoch=300; hs=256; temporalTest=2;
        % above are things to adjust. also consider 'varFile' below
        % by default all test are done on CONUS.
        %rt  = '/mnt/sdd/rnnSMAP/Database_SMAPgrid/Daily/';
        rt = ''; % empty if using default settings on each machine
        action = [1 2];
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);
        
        batchJobs(res,prob,action) % action contains 1: train; contains 2: test
    case 2
        % run through parfor
        nGPU =3; nMultiple=4; jobHead='hucv2n3'; epoch=300; hs=256; temporalTest=2;
        rt = ''; action = [1 2]; % empty if using default settings on each machine
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);
        
        batchJobs(res,prob,action,0) % action contains 1: train; contains 2: test
    case 3
        % an example of modifying parameter file
        p = [kPath.DBSMAP_L3,filesep,'Variable']; action = [1 2];
        v0 = importdata([p,'\varLst_Noah.csv']);
        vc0 = importdata([p,'\varConstLst_Noah.csv']);
        vn0 = importdata([p,'\varLst_NoModel.csv']);
        loc = ismember(v0,vn0); % if loc==1, it means this variable is not in vn
        nGPU =1; nMultiple=3; jobHead='CONUSv4f1'; epoch=300; hs=256; temporalTest=2;
        % jobHead: for both output and training set naming.
        toDropC = {'IrriSq','flag_Capa','flag_vegetation'};
        % Backward
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);
        for i=1:length(toDropC) % removing one variable at a time.
            k = ismember(vc0,toDropC{i}); vc=vc0; vc(k)=[];
            filename = ['varConstLst',num2str(i),'.csv']; 
            file = [p,filesep,filename]; writetable(cell2table(vc),file);
            prob.varCFile{i} = filename;
        end
        batchJobs(res,prob,action,1)
end
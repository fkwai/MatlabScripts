function [outNameLst,dataNameLst,optLst]=findJobHead(jobHead,varargin)
% pick outFolders match given pattern. 

% input:
% jobHead - head pattern of jobs output folder
% varargin{1} - optional root folder. Default to be kPath.OutSMAP_L3

% output:
% outNameLst - list of outName
% dataNameLst - list of train data set name
% optLst - all options included

% example:
%{
jobHead='hucv2n2';
rootOut='E:\Kuai\rnnSMAP_outputs\hucv2nc2\';
[outNameLst,dataNameLst,optLst]=findJobHead(jobHead,'rootOut',rootOut);
%}

global kPath
if isempty(varargin)
    rootOut=kPath.OutSMAP_L3;
else
    rootOut=varargin{1};
end

%% initialize
outLst = dir([rootOut,filesep,jobHead,'*']); 
outNameLst={outLst.name}';
nOut=length(outNameLst);
dataNameLst=cell(nOut,1);

%% read options and dataName
for k=1:nOut
    outName=outNameLst{k};
    optFile=[rootOut,filesep,outName,filesep,'opt.txt'];
    opt=readRnnOpt(outName,rootOut);
    optLst(k)=opt;
    dataNameLst{k}=opt.train;
end


end


function [outNameLst,optLst]=findJobHead(jobHead,varargin)
% pick outFolders match given pattern.

% input:
% jobHead - head pattern of jobs output folder
% varargin{1} - optional root output folder. Default to be kPath.OutSMAP_L3

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
outLst(~[outLst.isdir])=[];
outNameLst={outLst.name}';
nOut=length(outNameLst);

%% read options and dataName
optLst=[];
if nOut~=0
    for k=1:nOut
        outName=outNameLst{k};
        opt=readRnnOpt(outName,rootOut);
        optLst=[optLst;opt];
    end
else
    disp('No Output Case found!')
end


end


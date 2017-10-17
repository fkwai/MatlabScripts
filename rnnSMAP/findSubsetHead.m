function [dataNameLst]=findSubsetHead(jobHead,varargin)
% pick subsets match given pattern.

% input:
% jobHead - head pattern of jobs output folder
% varargin{1} - optional root database folder. Default to be kPath.DBSMAP_L3

% output:
% dataNameLst - list of subset names

% example:
%{
jobHead='hucv2n2';
rootOut='E:\Kuai\rnnSMAP_inputs\hucv2nc2\';
[dataNameLst]=findSubsetHead(jobHead,varargin)
%}

global kPath
if isempty(varargin)
    rootDB=kPath.DBSMAP_L3;
else
    rootDB=varargin{1};
end

%% initialize
SubsetFileLst = dir([rootDB,filesep,'Subset',filesep,jobHead,'*.csv']);
if length(SubsetFileLst)~=0
    dataNameLst = cellfun(@(x) x(1:end-4), {SubsetFileLst.name}','un',0);
else
    disp('No Database found!')
end



end


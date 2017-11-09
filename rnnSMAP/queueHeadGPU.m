function queueHeadGPU(fid,res,jobN,varargin)
% a job is nGPU + the same amount of CPU
% this script is printed for the overall controller script at the login node.
% 

i=1;
systemName = 'xstream'; %maybe later we get this automatically
if length(varargin)>0 && ~isempty(varargin{1})
    systemName = varargin{1};
end

if strcmp(systemName,'xstream')
    lines{i} = '#!/bin/bash';i=i+1;
    lines{i} = '#';i=i+1;
    lines{i} = ['#SBATCH --job-name=',jobN];i=i+1;
    lines{i} = ['#SBATCH --output=res_',jobN,'.txt'];i=i+1;
    lines{i} = '#';i=i+1;
    lines{i} = ['#SBATCH --time=',res.t];i=i+1;
    lines{i} = ['#SBATCH --ntasks=',num2str(res.nGPU)];i=i+1;
    % nConc works on 1 GPU and 1 CPU
    % 1CPU---matches---1CPU
    lines{i} = '#SBATCH --cpus-per-task=1';i=i+1;
    if ischar(res.memMB), mem=str2num(res.memMB); else, mem=res.memMB; end
    lines{i} = ['#SBATCH --mem-per-cpu=',num2str(mem*ceil(res.nConc/res.nGPU))];i=i+1;
    lines{i} = ['#SBATCH --gres gpu:',num2str(res.nGPU)];i=i+1;
    lines{i} = '#SBATCH --gres-flags=enforce-binding';
    lines{i} = ['export LD_LIBRARY_PATH=/home/kxf227/torch/install/lib'];
    lines{i} = 'nvidia-smi > nvLog';
else
    lines = {};
end
% setup environment
for i=1:length(lines)
    fprintf(fid,'%s\n',lines{i});
end

%=$!  store last job id
%{
#!/bin/bash
#
#SBATCH --job-name=test
#SBATCH --output=res.txt
#
#SBATCH --time=10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=500
#SBATCH --gres gpu:8
#SBATCH --gres-flags=enforce-binding
%}


%{
sbatch submit.sh
%8 GPU per node.
%2 days max
%}
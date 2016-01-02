function [ out ] = checkMatNc(file)
%CHECKMATNC Summary of this function goes here
%   This function will check if filename.nc/mat is exist, if not we will
%   check if filename.mat/nc is exist, and return the file name with
%   correct extension. If can not find any exist file a error will be
%   returned.

[pathstr,name,ext]=fileparts(file);
ncfile=[pathstr,'\',name,'.nc'];
matfile=[pathstr,'\',name,'.mat'];
if exist(ncfile,'file')
    out=ncfile;
elseif exist(matfile,'file')
    out=matfile;
else
    error(['failed to find default file (',name,')'])
end


end


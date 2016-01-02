function [ data ] = readGPdata( file, field )
%READGPDATA Summary of this function goes here
%   Detailed explanation goes here
if strcmp(file(end-1:end), 'nc') 
    data = ncread(file,field);
elseif strcmp(file(end-2:end), 'mat') 
    temp=load(file,field);
    data=temp.(field);
end

end


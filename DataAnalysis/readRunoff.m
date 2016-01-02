function [ Q, t ,hucid] = readRunoff( filename, nrow )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% filename='E:\work\DataAnaly\USGSQ\huc4_runoff_mv01d\mv01d_row_data.txt';
% nrow=205;

fid=fopen(filename);
text=textscan(fid,'%s');
nr=nrow;
nc=length(text{1,1})/nr;
textre=reshape(text{1,1},nc,nr);
value=cellfun(@str2num, textre(2:end,2:end));
t=cellfun(@str2num, textre(2:end,1));
hucid=cellfun(@str2num, textre(1,2:end));
fclose(fid)
Q=value;

end


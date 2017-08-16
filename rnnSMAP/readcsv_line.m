function out= readcsv_ind(csvFile,indRow)
%READCSV_IND Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(csvFile);

count=0;
out=[];
tic
while 1;
    % get a line of text
    tline = fgetl(fid);
    count=count+1;
    
    if tline == -1;
        break;
    end

    % check modulus of count for every 2nd and 11th line
    if mod(count,11) == 1;
        tline_2nd = tline;
    elseif mod(count,11) == 10;
        tline_11th = tline;
        % do something with the 2nd and 11th lines ("associate" them)
    end


end
fclose(fid)
toc

end


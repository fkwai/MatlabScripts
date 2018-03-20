function out= readVarLst(varLstFile)
% read varLst file

fid = fopen(varLstFile);
out={};
while 1
    % get a line of text
    tline = fgetl(fid);
    if tline == -1
        break;
    end
    out=[out;{tline}];
end
fclose(fid);

end


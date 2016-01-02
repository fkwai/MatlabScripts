function GRACE2text( GRACEmat,file )
%GRACE2TEXT Summary of this function goes here
%   see data2text.m
GRACE=load(GRACEmat);
loc=GRACE.LOCATIONS';
data=GRACE.DATA'*10;
data(abs(data)>5000)=nan;
month=str2num(datestr(GRACE.T,'yyyymm'));
fileID = fopen(file,'w');
fm1 = ['%10s','%10s',repmat(['%10i'],1,length(month)),'\n'];
fm2 = ['%10.2f','%10.2f',repmat(['%10.3f'],1,length(month)),'\n'];
fprintf(fileID,fm1,'lon','lat',month);
fprintf(fileID,fm2,[loc,data]');
fclose(fileID);

end


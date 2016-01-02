function GLDAS2text( GLDASmat,crd, t,file )
%NLDAS2TEXT Summary of this function goes here
%   Detailed explanation goes here

loc=crd;
data=GLDASmat;
month=t;

fileID = fopen(file,'w');
fm1 = ['%10s','%10s',repmat(['%10i'],1,length(month)),'\n'];
fm2 = ['%10.2f','%10.2f',repmat(['%10.3f'],1,length(month)),'\n'];
fprintf(fileID,fm1,'lon','lat',month);
fprintf(fileID,fm2,[loc,data]');
fclose(fileID);


end


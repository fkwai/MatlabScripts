function Set_Parameter_Table( gribTab )
% update from read_grib code.
%gribTab='Y:\GLDAS\gribtab_GLDAS_NOAH.txt';

global Parameter_Table

T=table2cell(readtable(gribTab,'Delimiter',':'));
indall=cell2mat(T(:,1));
partab=repmat({{'-',   'Unused ',   '-'}},max(indall)+1,1);
partab{1}={'var0','undefined',''};

for i=1:length(indall)
    ind=indall(i)+1;
    partab{ind}{1}=T{i,2};
    str=T{i,3};
    
    C = strsplit(str,' ');
    while strcmp(C{end},'')
        C(end)=[];
    end
    partab{ind}{2}=strjoin(C(1:end-1),' ');
    partab{ind}{3}=C{end};
end
Parameter_Table=partab;
end


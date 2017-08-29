function scanDatabaseNLDAS(dbName,writeVar)
% this function will scan given database and write varLst.csv and varConstLst.csv

global kPath
dirDB=[kPath.DBNLDAS,dbName,kPath.s];
dirVar=[kPath.DBNLDAS,'Variable',kPath.s];

varLst={};
varConstLst={};
fileLst=dir([dirDB,'*.csv']);
for k=1:length(fileLst)
	varName=fileLst(k).name(1:end-4);
	if ~strcmp(varName,'crd') && ...
		~strcmp(varName,'time') && ...
		~startsWith(varName,'var') && ...
		~endsWith(varName,'_stat') && ...
		~startsWith(varName,'LSOIL_0-10') && ...
		~startsWith(varName,'SOILM_0-10')
		if startsWith(varName,'const_')
			varConstLst=[varConstLst;varName(7:end)];
        else
            varLst=[varLst;varName];
        end
        
        % fix 0 std
        statFile=[dirDB,varName,'_stat.csv'];
        stat=csvread(statFile);
        if stat(4)<0.005
            disp(varName)
            stat(4)=1;
            dlmwrite(statFile, stat,'precision',8);
        end        
    end
end

if writeVar==1
    fid=fopen([dirVar,'varLst.csv'],'w');
    fprintf(fid,'%s\n',varLst{:});
    fclose(fid);
    
    fid=fopen([dirVar,'varConstLst.csv'],'w');
    fprintf(fid,'%s\n',varConstLst{:});
    fclose(fid);
end

end

function b = startsWith(s, pat)
sl = length(s);
pl = length(pat);
b = (sl >= pl && strcmp(s(1:pl), pat)) || isempty(pat);
end

function b = endsWith(s, pat)
sl = length(s);
pl = length(pat);
b = (sl >= pl && strcmp(s(end-pl+1:end), pat)) || isempty(pat);
end


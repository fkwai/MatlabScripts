function scanDatabase(dbName)
% this function will scan given database and write varLst.csv and varConstLst.csv

global kPath
dirDB=[kPath.DBSMAP_L3,dbName,kPath.s];

varLst={};
varConstLst={};
fileLst=dir([dirDB,'*.csv']);
for k=1:length(fileLst)
	varName=fileLst(k).name(1:end-4);
	if ~strcmp(varName,'crd') && ...
		~strcmp(varName,'time') && ...
		~startsWith(varName,'var') && ...
		~endsWith(varName,'_stat') && ...
		~startsWith(varName,'SMAP')
		if startsWith(varName,'const_')
			varConstLst=[varConstLst;varName];
		else
			varLst=[varLst;varName];
			%{
			statFile=[dirDB,varName,'_stat.csv'];
			stat=csvread(statFile);
			if stat(4)==0
				disp(varName)
				stat(4)=1;
				dlmwrite(statFile, stat,'precision',8);
			end
			%}
		end
	end
end

fid=fopen([dirDB,'varLst.csv'],'w');
fprintf(fid,'%s\n',varLst{:});
fclose(fid);

fid=fopen([dirDB,'varConstLst.csv'],'w');
fprintf(fid,'%s\n',varConstLst{:});
fclose(fid);


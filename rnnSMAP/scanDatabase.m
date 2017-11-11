function outVar=scanDatabase(dbName,writeVar)
% this function will scan given database and write varLst.csv and varConstLst.csv

global kPath
dirDB=[kPath.DBSMAP_L3,dbName,kPath.s];
dirVar=[kPath.DBSMAP_L3,'Variable',kPath.s];

varLst={};
varConstLst={};
outVar={};
fileLst=dir([dirDB,'*.csv']);
for k=1:length(fileLst)
	varName=fileLst(k).name(1:end-4);
	if ~strcmp(varName,'crd') && ...
		~strcmp(varName,'time') && ...
		~startsWith(varName,'var') && ...
		~endsWith(varName,'_stat') && ...
		~startsWith(varName,'SMAP')
		if startsWith(varName,'const_')
			varConstLst=[varConstLst;varName(7:end)];
        else
            varLst=[varLst;varName];
        end
        
        %% fix 0 std
        
        statFile=[dirDB,varName,'_stat.csv'];
        stat=csvread(statFile);
        if stat(4)<=0.002
            disp(varName)
            stat(4)=1;
            dlmwrite(statFile, stat,'precision',8);
        end
        
        
        %% do log
        %{
        if ~startsWith(varName,'const_')    
            tic
            disp(varName)
            dataFile=[dirDB,varName,'.csv'];
            data=csvread(dataFile);
            stat=calculateStat(data);
            toc
            if stat(4)<0.01
                % do log                
                outVar=[outVar,varName];
                varLogName=[varName,'_log'];
                varLst=[varLst;varLogName];
                disp(['doing log for ', varName])
                data(data==-9999)=nan;
                output=log(data+1);
                output(isnan(output))=-9999;
                outFile=[dirDB,varName,'_log.csv'];
                dlmwrite(outFile,output,'precision',8);
                statOutput=calculateStat(output);
                statOutputFile=[dirDB,varName,'_log_stat.csv'];
                dlmwrite(statOutputFile, statOutput,'precision',8);
            end
        end
        %}
        
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

function stat=calculateStat(data)
vecOutput=data(:);
vecOutput(vecOutput==-9999)=[];
perc=10;
lb=prctile(vecOutput,perc);
ub=prctile(vecOutput,100-perc);
data80=vecOutput(vecOutput>=lb &vecOutput<=ub);
m=mean(data80);
sigma=std(data80);
stat=[lb;ub;m;sigma];
end


function outVar=scanDatabase(dbName,writeVar,varargin)
% this function will scan given database and write varLst.csv and varConstLst.csv

global kPath

pnames={'dirRoot','doLog','doZero'};
dflts={kPath.DBSMAP_L3,0,0};
[dirRoot,doLog,doZero]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

dirDB=[dirRoot,dbName,kPath.s];
dirVar=[dirRoot,'Variable',kPath.s];

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
            ~endsWith(varName,'_backup') && ...
            ~startsWith(varName,'SMAP')
        if startsWith(varName,'const_')
            varConstLst=[varConstLst;varName(7:end)];
        else
            varLst=[varLst;varName];
        end
        
        
        %% fix 0 std
        if doZero
            statFile=[dirDB,varName,'_stat.csv'];
            stat=csvread(statFile);
            if stat(4)<=0.001
                disp(varName)
                copyfile(statFile,[dirDB,varName,'_stat_backup.csv'])
                stat(4)=1;
                dlmwrite(statFile, stat,'precision',8);
            end
        end
        
        %% do log
        if doLog
            if ~startsWith(varName,'const_') && ~endsWith(varName,'_log')
                statFile=[dirDB,varName,'_stat.csv'];
                stat=csvread(statFile);
                tic
                disp(varName)
                dataFile=[dirDB,varName,'.csv'];
                if stat(4)<0.001
                    data=csvread(dataFile);
                    stat=calculateStat(data);
                    toc
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
        end
    end
end

if writeVar==1
    mkdir(dirVar)
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


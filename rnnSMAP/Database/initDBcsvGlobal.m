function initDBcsvGlobal(dirDB,yrLst,yrSD,crd)
% initlize yearly database for global dataset
% will create database has one folder for each year from yrSD to next
% year yrSD. 

% for example following will create one folder for 20000401 - 20010401 and
% named as 2000
% yrLst=2000:2016;
% yrSD=0401;

%% write crd
crdFile=[dirDB,'crd.csv'];
dlmwrite(crdFile,crd,'precision',12);

%% year database
for k=1:length(yrLst)
    yr=yrLst(k);
    yrStr=num2str(yr);
    sd=yr*10000+yrSD;
    ed=(yr+1)*10000+yrSD;
    dirDByear=[dirDB,yrStr,filesep];
    
    
    if ~isdir(dirDByear)
        mkdir(dirDByear)
    end

    timeFile=[dirDByear,'time.csv'];
    sdn=datenumMulti(sd,1);
    edn=datenumMulti(ed,1)-1;
    tnum=[sdn:edn]';
    dlmwrite(timeFile,tnum,'precision',12);
end
        
%% const database
dirDBconst=[dirDB,'const',filesep];
mkdir(dirDBconst)

end


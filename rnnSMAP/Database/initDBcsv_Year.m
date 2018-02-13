function initDBcsv_Year(dirDB,yrLst,yrSD,maskMat)
% initlize yearly database for global dataset
% will create database has one folder for each year from yrSD to next
% year yrSD. 

% for example following will create one folder for 20000401 - 20010401 and
% named as 2000
% yrLst=2000:2016;
% yrSD=0401;

%% year database
for k=1:length(yrLst)
    yr=yrLst(k);
    yrStr=num2str(yr);
    sd=yr*10000+yrSD;
    ed=(yr+1)*10000+yrSD;
    dirDByear=[dirDB,yrStr,filesep];
    initDBcsv( maskMat,dirDByear,sd,ed )
end

%% const database
initDBcsv(maskMat,[dirDB,'const',filesep],1,1)

end


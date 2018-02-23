
%% move old CONUS data to new dataset
rootDB='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3_test/';
dataName='CONUSv4f1';

dirDB=[rootDB,filesep,dataName,filesep];
tnum=csvread([dirDB,'time.csv']);
crd=csvread([rootDB,'crd.csv']);

initDBcsvGlobal(dirDB,[2015:2016],0401,crd)
t1=csvread([dirDB,'2015/time.csv']);
t2=csvread([dirDB,'2016/time.csv']);

fileLst=dir([dirDB,'*.csv']);
for k=1:length(fileLst)
    varName=fileLst(k).name(1:end-4);
    varName
    tic
    if ~strcmp(varName,'time') &&...
            ~strcmp(varName,'crd')
        data=csvread([dirDB,varName,'.csv']);
        [~,ind1,~]=intersect(tnum,t1);
        [~,ind2,~]=intersect(tnum,t2);
        data1=data(:,ind1);
        data2=data(:,ind2);
        dlmwrite([dirDB,'2015/',varName,'.csv'],data1,'precision',8);
        dlmwrite([dirDB,'2016/',varName,'.csv'],data2,'precision',8);        
    end
    toc
end

dirConst=[dirDB,'const/'];
fileLst=dir([dirConst,'const_*.csv']);
for k=1:length(fileLst)
    varName=fileLst(k).name(7:end-4);
    data=csvread([dirConst,'const_',varName,'.csv']);
    dlmwrite([dirConst,varName,'.csv'],data,'precision',8);
end


%% test on old CONUS data
rootDB='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3_test/'
rootOut=kPath.OutSMAP_L3_Global;
outName1='CONUSv4f1_Forcing';
outName2='CONUSv4f1_Noah';
dataName='CONUSv4f1';

%postRnnGlobal_map(outName2,dataName,'rootOut',rootOut,'rootDB',rootDB,'targetName','SMAP','modelField','LSOIL_0-10')

out={};
out{1,1}= postRnnGlobal_load(outName1,dataName,[2015,2015],'rootDB',rootDB,'targetName','SMAP','modelField','LSOIL_0-10');
out{1,2}= postRnnGlobal_load(outName1,dataName,[2016,2016],'rootDB',rootDB,'targetName','SMAP','modelField','LSOIL_0-10');
out{2,1}= postRnnGlobal_load(outName2,dataName,[2015,2015],'rootDB',rootDB,'targetName','SMAP','modelField','LSOIL_0-10');
out{2,2}= postRnnGlobal_load(outName2,dataName,[2016,2016],'rootDB',rootDB,'targetName','SMAP','modelField','LSOIL_0-10');

stat={};
boxMat={};
for j=1:2
    for i=1:2
        stat{j,i}=statCal(out{j,i}.yLSTM,out{j,i}.ySMAP);
        boxMat{j,i}=stat{j,i}.rmse;
    end
end

labelX={'train','test'};
labelY={'Forcing','Noah'};
f=plotBoxSMAP( boxMat,labelX,labelY,'yRange',[0,0.1])
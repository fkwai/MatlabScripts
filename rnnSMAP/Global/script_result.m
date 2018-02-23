
%% new test
rootOut=kPath.OutSMAP_L3_Global;
rootDB=kPath.DBSMAP_L3_Global;
% outName1='Globalv8f1_Forcing';
% outName2='Globalv8f1_Noah';
% dataName='Globalv8f1';
outName1='CONUSv4f4_Forcing_GPM';
outName2='CONUSv4f4_Noah_GPM';
dataName='CONUSv4f4';

postRnnGlobal_map(outName2,dataName)

out={};
out{1,1}= postRnnGlobal_load(outName1,dataName,[2015,2015]);
out{1,2}= postRnnGlobal_load(outName1,dataName,[2016,2016]);
out{2,1}= postRnnGlobal_load(outName2,dataName,[2015,2015]);
out{2,2}= postRnnGlobal_load(outName2,dataName,[2016,2016]);

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

%% pick out CONUS cells
bb=[-125,-66;25,50];
crd=out{1,1}.crd;
indPick=find(crd(:,1)>bb(2,1)&crd(:,1)<bb(2,2)&crd(:,2)>bb(1,1)&crd(:,2)<bb(1,2));

stat={};
boxMat={};
for j=1:2
    for i=1:2
        stat{j,i}=statCal(out{j,i}.yLSTM(:,indPick),out{j,i}.ySMAP(:,indPick));
        boxMat{j,i}=stat{j,i}.rmse;
    end
end

labelX={'train','test'};
labelY={'Forcing','Noah'};
f=plotBoxSMAP( boxMat,labelX,labelY,'yRange',[0,0.1])

%% run file compare
rf1=csvread('/mnt/sdb1/rnnSMAP/output_SMAPgrid_global/CONUSv4f1_Noah/runFile.csv');
rf2=csvread('/mnt/sdb1/rnnSMAP/output_SMAPgrid_global/Globalv8f1_Noah/runFile.csv');

plot(1:500,rf1,'b');hold on
plot(1:500,rf2,'r');hold off















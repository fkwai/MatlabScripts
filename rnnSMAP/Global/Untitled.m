
rootOut=kPath.OutSMAP_L3_Global;
rootDB=kPath.DBSMAP_L3_Global;
outName1='Globalv8f1_Forcing';
outName2='Globalv8f1_Noah';
dataName='Globalv8f1';

postRnnGlobal_map(outName,dataName,'rootOut',rootOut,'rootDB',rootDB)

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

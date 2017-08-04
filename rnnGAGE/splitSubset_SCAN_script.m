load('H:\Kuai\rnnGAGE\databaseSCAN\matValid.mat')

depthLst=[2,4,6,8,12,15,20,40,60,80];

indLst=find(matValid(:,8)==1&matValid(:,1)==1&matValid(:,2)==1&matValid(:,4)==1);

saveFile=[kPath.DBSCAN,'CONUS',kPath.s,'indLst.csv'];
dlmwrite(saveFile, indLst,'precision',8);


data1=csvread([kPath.DBSMAP_L3_CONUS,'\SMAP.csv']);
data2=csvread([kPath.DBSMAP_L3_CONUS,'\SOILM.csv']);
data1(data1==-9999)=nan;
data2(data2==-9999)=nan;
data2=data2/100;


crd=csvread([kPath.DBSMAP_L3_CONUS,'\crd.csv']);
[grid1,xx,yy] = data2grid3d( data1,crd(:,2),crd(:,1));
[grid2,xx,yy] = data2grid3d( data2,crd(:,2),crd(:,1));



tsStr(1).grid=grid1;
tsStr(1).t=1:size(grid1,3);
tsStr(1).symb='-r';
tsStr(1).legendStr='SMAP';


tsStr(2).grid=grid2;
tsStr(2).t=1:size(grid2,3);
tsStr(2).symb='-b';
tsStr(2).legendStr='NLDAS';


showGrid( nanmean(grid2,3),[1:length(xx)],[length(yy):-1:1]',1,'tsStr',tsStr)


%%
[xOut,yOut,xStat,yStat] = readDatabaseSMAP2('CONUSs4f1');
x=zeros(size(xOut))*nan;
xOut(xOut==-9999)=nan;
for k=1:size(xOut,3)
    x(:,:,k)=(xOut(:,:,k)-xStat(3,k))./xStat(4,k);
end

ind=find(x>1000);
[jj,ii,kk]=ind2sub(size(x),ind);
unique(kk)


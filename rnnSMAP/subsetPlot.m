function subsetPlot(subsetName)
% plot the subset of given subsetFile name
% subsetName - name of subset file

global kPath
subsetFile=[kPath.DBSMAP_L3,'Subset',kPath.s,subsetName,'.csv'];

%% CONUS crd
crdFileCONUS=[kPath.DBSMAP_L3,'CONUS',kPath.s,'crd.csv'];
crdCONUS=csvread(crdFileCONUS);

%% read subset index
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);

%% read root and subset crd
crdFile=[kPath.DBSMAP_L3,rootName,kPath.s,'crd.csv'];
crd=csvread(crdFile);
if indSub(1)==-1
    crdSub=crd;
else
    crdSub=crd(indSub,:);
end

%% plot
f=figure('Position',[200,200,1000,600]);
plot(crdCONUS(:,2),crdCONUS(:,1),'b.');hold on
plot(crdSub(:,2),crdSub(:,1),'ro');hold off

end


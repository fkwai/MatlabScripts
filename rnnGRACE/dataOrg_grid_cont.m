%% continent each point belong to
load('indMask.mat')
xland=x(indMask);
yland=y(indMask);

shapefile='Y:\Maps\WorldContinents.shp';
shape=shaperead(shapefile);
cont=zeros(length(indMask),1);

for i=1:length(shape)
    i
    indpoly=[0,find(isnan(shape(i).X))];    
    for j=1:length(indpoly)-1
        X=shape(i).X(indpoly(j)+1:indpoly(j+1)-1);
        Y=shape(i).Y(indpoly(j)+1:indpoly(j+1)-1);        
        inout = int32(zeros(size(xland)));
        pnpoly(X,Y,xland,yland,inout);
        inout=double(inout);
        cont(inout==1)=i;
    end
end
save cont cont

mapcont=rnnPred2map(cont);

%% read and save
FieldList={'Rainf','Snowf','Qair','Wind','LWnet','SWnet','SoilM','SWE',...
     'Canopint','GRACE','SErr','Silt','Clay','Sand','Ndvi'};
FieldList={'Silt','Clay','Sand','Ndvi'};

dataDir='E:\Kuai\rnnGRACE\data\';
prefix='gridTab';
saveDir=[dataDir,'\contTest\'];
if ~isdir(saveDir)
    mkdir(saveDir);
end

for i=1:length(FieldList)
    for c=[1,2];
        c
        field=FieldList{i};
        datafile=[dataDir,prefix,field,'_norm.csv'];
        data=csvread(datafile);
        [pathstr,name,ext] = fileparts(datafile);
        fileTrain=[saveDir,name,'_train_',num2str(c),'.csv'];
        fileTest=[saveDir,name,'_test_',num2str(c),'.csv'];
        dataTrain=data(cont~=c,:);
        dataTest=data(cont==c,:);
        dlmwrite(fileTrain, dataTrain, 'precision',16)
        dlmwrite(fileTest, dataTest, 'precision',16)
    end
end

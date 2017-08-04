
sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';

indName='indSel';
epoch=500;
global kPath
dataFolder=[kPath.DBSCAN,'CONUS',kPath.s];
outFolder=[kPath.OutSCAN,indName,kPath.s];
%outFolder=[kPath.OutSCAN,indName,'_noModel',kPath.s];

indLst=csvread([dataFolder,indName,'.csv']);
nS=length(indLst);

trainFile=[outFolder,'out_CONUS_CONUS_',num2str(epoch),kPath.s,sprintf('%06d',nS),'_train.csv'];
testFile=[outFolder,'out_CONUS_CONUS_',num2str(epoch),kPath.s,sprintf('%06d',nS),'_test.csv'];
xData1=csvread(trainFile);
xData2=csvread(testFile);
xData=[xData1;xData2];

%% plot Map
f=figure
shape=shaperead('H:\Kuai\map\USA.shp');
plot([shape.X], [shape.Y],'Color','k','LineWidth',1);hold on
tab=readtable([kPath.SCAN,'nwcc_inventory_CONUS.csv']);
lat=tab.lat(indLst);
lon=tab.lon(indLst);
plot(lon,lat,'r*')
axis equal

bb=1;
while(bb)
    figure(f)
    [px,py]=ginput(1);
    [minDist,k]=min(abs(px-lon)+abs(py-lat));
    
    %% plot ts
    fc=figure();    
    if minDist>10
        bb=0;
        if exist('fc','var')
            close(fc)
        end
    else
        figure(fc);
        siteInd=indLst(k);
        yField='soilM_SCAN_40';
        yData=csvread([dataFolder,yField,'.csv']);
        yStat=csvread([dataFolder,yField,'_stat.csv']);
        yMean=yStat(3);
        yStd=yStat(4);
        y=yData(siteInd,:);
        x=xData(:,k)*yStd+yMean;
        
        yField='LSOIL_40-100';
        yData=csvread([dataFolder,yField,'.csv']);
        y1=yData(siteInd,:)./6;
        
        yField='LSOIL_100-200';
        yData=csvread([dataFolder,yField,'.csv']);
        y2=yData(siteInd,:)./10;
        
        plot(tnum,x,'-r');hold on
        plot(tnum,y,'-b');hold on
        plot(tnum,y1,'--k');hold on
        plot(tnum,y2,'-k');hold off
        title(num2str(siteInd))
        legend('LSTM','SCAN 100 cm','NOAH 40-100 cm','NOAH 100-120 cm','location','northwest')
    end
end


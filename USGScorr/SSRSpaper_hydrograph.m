
%% read usgs data
% load('E:\Chaopeng\AMHG\usgs'); % streamflow.
% D = importdata('E:\users\cshen\Documents\GagesII.xlsx');
% for i=1:9067
%     IDs(i)=str2num(D.textdata.Sheet1{i+1,1}); 
%     Lat(i)= D.data.Sheet1(i,3);
%     Long(i)=D.data.Sheet1(i,4); 
% end
% IDs=IDs'; Lat=Lat'; Long=Long'; Area = D.data.Sheet1(:,1);
% for i=1:length(usgs)
%     k =find(IDs==str2num(usgs(i).name),1,'first'); 
%     usgs(i).Lat = Lat(k); 
%     usgs(i).Lon = Long(k); 
%     usgs(i).area=Area(k); 
% end

%% find out gages in ohio/indiana
shpOH=shaperead('Y:\Maps\State\OH.shp');
shpIN=shaperead('Y:\Maps\State\IN.shp');
shpGA=shaperead('Y:\Maps\State\GA.shp');
shpSC=shaperead('Y:\Maps\State\SC.shp');
shape=[shpOH,shpIN,shpGA,shpSC];

xGage=[usgs.Lon];
yGage=[usgs.Lat];
for k=1:4
    shpClip=shape(k);
    X=shpClip.X(1:end-1);
    Y=shpClip.Y(1:end-1);
    inout = int32(zeros(size(xGage)));
    pnpoly(X,Y,xGage,yGage,inout);
    inout=double(inout);
    indC{k}=find(inout==1);
end
indGage1=[indC{1},indC{2}]';
usgsSel1=usgs(indGage1);
indGage2=[indC{3},indC{4}]';
usgsSel2=usgs(indGage2);

% plot(xGage(indGage1),yGage(indGage1),'b*');hold on
% plot(xGage(indGage2),yGage(indGage2),'ro');hold on
% plot(shpOH.X,shpOH.Y,'--k');hold on
% plot(shpIN.X,shpIN.Y,'--k');hold on
% plot(shpGA.X,shpGA.Y,'--k');hold on
% plot(shpSC.X,shpSC.Y,'--k');hold off

%% summarize to table
sd=200710;
ed=200909;
tnum=datenumMulti(sd,1):datenumMulti(ed,1);
tab1=zeros(length(tnum),length(usgsSel1))*nan;
tab2=zeros(length(tnum),length(usgsSel2))*nan;
crd1=zeros(length(usgsSel1),2)*nan;
crd2=zeros(length(usgsSel2),2)*nan;
area1=zeros(length(usgsSel1),1)*nan;
area2=zeros(length(usgsSel2),1)*nan;
id1=zeros(length(usgsSel1),1)*nan;
id2=zeros(length(usgsSel2),1)*nan;
for i=1:length(usgsSel1)
    v=usgsSel1(i).v;
    t=usgsSel1(i).t;
    [C,ind1,ind2]=intersect(t,tnum);
    tab1(ind2,i)=v(ind1);
    crd1(i,:)=[usgsSel1(i).Lat,usgsSel1(i).Lon];
    area1(i)=usgsSel1(i).area;
    id1(i)=str2num(usgsSel1(i).name); 
end
for i=1:length(usgsSel2)
    v=usgsSel2(i).v;
    t=usgsSel2(i).t;
    [C,ind1,ind2]=intersect(t,tnum);
    tab2(ind2,i)=v(ind1);
    crd2(i,:)=[usgsSel2(i).Lat,usgsSel2(i).Lon];
    area2(i)=usgsSel2(i).area;
    id2(i)=str2num(usgsSel2(i).name);
end
indNan1=find(isnan(mean(tab1)));
indNan2=find(isnan(mean(tab2)));
tab1(:,indNan1)=[];
tab2(:,indNan2)=[];
crd1(indNan1,:)=[];
crd2(indNan2,:)=[];
area1(indNan1)=[];
area2(indNan2)=[];
id1(indNan1)=[];
id2(indNan2)=[];
save('E:\Kuai\SSRS\paper\mB\usgs_Hydrograph.mat','tab1','tab2',...
    'crd1','crd2','area1','area2','id1','id2','tnum');

%% plot hydrograph of 2 gages
figure('Position',[500,500,1200,400]);
% med1=median(tab1);
% med2=median(tab2);
% gage1=randi([1,size(tab1,2)]);
% %[minV,gage2]=min(abs(med2-med1(gage1)));
% [minV,gage2]=min(abs(area2-area1(gage1)));
gageID1=4196000;
gageID2=2390000;
gage1=find(id1==gageID1);
gage2=find(id2==gageID2);
v1=tab1(:,gage1);
plot(tnum,v1,'-*b');hold on
v2=tab2(:,gage2);
plot(tnum,v2,'-or')
datetick('x','mmm');
xlim([tnum(1),tnum(end)])
ylim([0,prctile([v1;v2],99)])
hold off
xlabel('Month');
ylabel('Flow Rate (m^3/day)')
title('Hydrograph of two Stations')

figfolder='E:\Kuai\SSRS\paper\mB\';
fname=[figfolder,'hydrograph'];
fixFigure([],[fname,'.eps']);
saveas(gcf, fname);

%% plot map of 2 gages
figure('Position',[500,500,200,200]);
gageCrd1=crd1(gage1,:);
gageCrd2=crd2(gage1,:);
MarkerSize=10;
LineWidth=2;
plot(gageCrd1(2),gageCrd1(1),'b*','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(gageCrd2(2),gageCrd2(1),'ro','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
shpUSA=shaperead('Y:\Maps\USA.shp');
for j=1:length(shpUSA)
    plot(shpUSA(j).X,shpUSA(j).Y,'--k')
end
axis equal
xlim([-95,-75])
ylim([25,45])
set(gca,'xtick',[-90,-80],'ytick',[30,40]);
addDegreeAxis()

figfolder='E:\Kuai\SSRS\paper\mB\';
fname=[figfolder,'hydrographMap'];
fixFigure([],[fname,'.eps']);
saveas(gcf, fname);


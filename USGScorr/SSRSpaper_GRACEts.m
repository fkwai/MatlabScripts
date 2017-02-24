
%% read and find data
%load('Y:\GRACE\graceGrid_CSR.mat')
crd=[-79.5,41.5;-77.5,41.5];
n=size(crd,1);
v=zeros(length(t),n);
for k=1:n
    xInd(k)=find(x==crd(k,1));
    yInd(k)=find(y==crd(k,2));
    v(:,k)=graceGrid(yInd(k),xInd(k),:);
end

%% find annual peak and though
tYear=str2num(datestr(t,'yyyy'));
yrLst=unique(tYear);
vMax=zeros(length(yrLst)-1,2);
tMax=zeros(length(yrLst)-1,2);
vMin=zeros(length(yrLst)-1,2);
tMin=zeros(length(yrLst)-1,2);
for k=1:length(yrLst)-1
    temp=v(tYear==yrLst(k),:);
    vMax(k,:)=max(temp);    
    vMin(k,:)=min(temp);
    for kk=1:n
        tMax(k,kk)=t(find(v(:,kk)==vMax(k,kk)));
        tMin(k,kk)=t(find(v(:,kk)==vMin(k,kk)));
    end
end

%% plot
figure('Position',[500,500,1200,400]);
LineWidth=2;
for k=1:n
    subplot(1,2,k)
    plot(t,v(:,k),'r','LineWidth',LineWidth);hold on
    plot(tMax(:,k),vMax(:,k),'r*','LineWidth',LineWidth);hold on
    plot(tMin(:,k),vMin(:,k),'r*','LineWidth',LineWidth);hold on
    lineMax=mean(vMax(:,k));
    lineMin=mean(vMin(:,k));
    plot([t(1),t(end)],[lineMax,lineMax],'k--','LineWidth',LineWidth);hold on
    plot([t(1),t(end)],[lineMin,lineMin],'k--','LineWidth',LineWidth);hold on
    datetick('x','yy');
    xlabel('Year');
    if k==1
        ylabel('GRACE TWSA (cm)')    
    end
    xlim([t(1),t(end)])
end

figfolder='E:\Kuai\SSRS\paper\mB\';
fname=[figfolder,'GRACEts'];
fixFigure([],[fname,'.eps']);
saveas(gcf, fname);

CRNfile='Y:\SoilMoisture\CRN\MatFile\CRNmat_15_16';
load(CRNfile)
crdInd=csvread('Y:\Kuai\rnnSMAP\Database\tDB_SMPq\crdIndex.csv');
cellsize=0.25;
tSMAP=csvread('Y:\Kuai\rnnSMAP\Database\tDB_SMPq\tIndex.csv');
tstrSMAP=cellstr(num2str(tSMAP,'%08.4f'));
tnumSMAP=datenum(tstrSMAP,'yyyymmdd.HHMM');


%% plot background map
figFile='Y:\Kuai\rnnSMAP\output\trainNA3\fig_comb\nashMap_comb.fig';
f=openfig(figFile);hold on
colormap parula
%plot(crdInd(:,2),crdInd(:,1),'.r');hold on
plot(CRNmat.crd(:,2),CRNmat.crd(:,1),'or','LineWidth',2);hold off
g=[];
while(1)
    %% select point
    figure(f)
    [px,py]=ginput(1);
    dist=sqrt((CRNmat.crd(:,2)-px).^2+(CRNmat.crd(:,1)-py).^2);
    [C,indCRN]=min(dist);
    
    %% plot ts comp
    if ishandle(g);close(g);end
    g=figure('Position',[100,100,1500,600]);
    k=indCRN;
    crd=CRNmat.crd(k,:);
    crd0=round((crd+0.125)./cellsize).*cellsize-0.125;
    crd1=floor((crd+0.125)./cellsize).*cellsize-0.125;
    crd2=ceil((crd+0.125)./cellsize).*cellsize-0.125;
    ind0=find(crdInd(:,1)==crd0(1)&crdInd(:,2)==crd0(2));
    ind1=find(crdInd(:,1)==crd2(1)&crdInd(:,2)==crd2(2));
    ind2=find(crdInd(:,1)==crd2(1)&crdInd(:,2)==crd1(2));
    ind3=find(crdInd(:,1)==crd1(1)&crdInd(:,2)==crd1(2));
    ind4=find(crdInd(:,1)==crd1(1)&crdInd(:,2)==crd2(2));
    
    legendstr={};
    if sum(isnan(CRNmat.soilM(:,k)))~=length(CRNmat.soilM(:,k))
        plot(CRNmat.tnum,CRNmat.soilM(:,k),'--b');hold on
        legendstr=[legendstr,'CRN'];
    else
        disp('CRN all nan')
    end
    if ~isempty(ind0)
        fileSMAP=['Y:\Kuai\rnnSMAP\Database\tDB_SMPq\data\',num2str(ind0,'%06d'),'.csv'];
        vSMAP=csvread(fileSMAP);
        vSMAP(vSMAP==-9999)=nan;
        indval=find(~isnan(vSMAP));
        plot(tnumSMAP(indval),vSMAP(indval),'r-o');hold on
        legendstr=[legendstr,'SMAP'];
        
        fileGLDAS=['Y:\Kuai\rnnSMAP\Database\tDB_soilM\data\',num2str(ind0,'%06d'),'.csv'];
        vGLDAS=csvread(fileGLDAS)/100;
        vGLDAS(vGLDAS==-9999)=nan;
        indval=find(~isnan(vGLDAS));
        plot(tnumSMAP(indval),vGLDAS(indval),'k-');hold on
        legendstr=[legendstr,'GLDAS'];
    else
        for i=1:4
            eval(['ind=ind',num2str(i)]);
            if ~isempty(ind)
                fileSMAP=['Y:\Kuai\rnnSMAP\Database\tDB_SMPq\data\',num2str(ind,'%06d'),'.csv'];
                vSMAP=csvread(fileSMAP);
                vSMAP(vSMAP==-9999)=nan;
                indval=find(~isnan(vSMAP));
                plot(tnumSMAP(indval),vSMAP(indval),'r-o');hold on
                legendstr=[legendstr,['SMAP-Quad',numestr(i)]];
            end
        end
    end
    legend(legendstr)
    title(['SMAP vs CRN; [', num2str(crd(1)),';',num2str(crd(2)),']'])
    datetick('x','mmm')
end
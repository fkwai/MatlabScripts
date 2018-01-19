

kLst=find(abs(outMat(:,4))>5|abs(outMat(:,5))>5);

for i=1:length(kLst)
    k=kLst(i);
    ind=indTest(k);
    vSCAN=siteSCAN(k).soilM(:,1);
    tSCAN=siteSCAN(k).tnum;
    tSCANvalid=tSCAN(~isnan(vSCAN));
    vLSTM=LSTM.v(:,ind);
    tLSTM=LSTM.t;
    vSMAP=SMAP.v(:,ind);
    tSMAP=SMAP.t;
    
    tt1=datenumMulti(year(tSCANvalid(1))*10000+401);
    if tSCANvalid(1)<=tt1
        t1=tt1;
    else
        t1=datenumMulti((year(tSCANvalid(1))+1)*10000+401);
    end
    tt2=datenumMulti(year(tSCANvalid(end))*10000+401);
    if tSCANvalid(end)>=tt2
        t2=tt2;
    else
        t2=datenumMulti((year(tSCANvalid(end))-1)*10000+401);
    end
    
    v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
    v2SCAN=vSCAN(tSCAN>=t1&tSCAN<=t2);
    f=figure('Position',[1,1,1500,400]);
    plot(t1:t2,v2LSTM,'b*');hold on
    plot(t1:t2,v2SCAN,'r*');hold on
    plot(tSMAP,vSMAP,'ko');hold on
    sensLSTM=sensSlope(v2LSTM,[t1:t2]','doPlot',1,'color','b');hold on
    sensSCAN=sensSlope(v2SCAN,[t1:t2]','doPlot',1,'color','r');hold off
    title([num2str(siteSCAN(k).ID,'%04d'),' [',num2str(siteSCAN(k).crd(1)),...
        ' ',num2str(siteSCAN(k).crd(2)),']'])
    legend(['LSTM ', num2str(sensLSTM.sen*365*1000,'%0.3f')],...
        ['SCAN ', num2str(sensSCAN.sen*365*1000,'%0.3f')])
    datetick('x','yy/mm')
    
    figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/scan/L3/';
    saveas(f,[figFolder,num2str(siteSCAN(k).ID,'%04d'),'.fig'])
    close(f)
end
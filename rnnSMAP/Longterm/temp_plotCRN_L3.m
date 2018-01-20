

kLst=find(abs(outMat(:,4))>0.5|abs(outMat(:,5))>0.5);

for i=1:length(kLst)
    k=kLst(i);
    ind=indTest(k);
    vCRN=siteCRN(k).soilM(:,1);
    tCRN=siteCRN(k).tnum;
    tCRNvalid=tCRN(~isnan(vCRN));
    vLSTM=LSTM.v(:,ind);
    tLSTM=LSTM.t;
    vSMAP=SMAP.v(:,ind);
    tSMAP=SMAP.t;
    tt1=datenumMulti(year(tCRNvalid(1))*10000+401);
    if tCRNvalid(1)<=tt1
        t1=tt1;
    else
        t1=datenumMulti((year(tCRNvalid(1))+1)*10000+401);
    end
    tt2=datenumMulti(year(tCRNvalid(end))*10000+401);
    if tCRNvalid(end)>=tt2
        t2=tt2;
    else
        t2=datenumMulti((year(tCRNvalid(end))-1)*10000+401);
    end
    
    if t1<t2
        v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
        v2CRN=vCRN(tCRN>=t1&tCRN<=t2);
        f=figure('Position',[1,1,1500,400]);
        plot(t1:t2,v2LSTM,'b*');hold on
        plot(t1:t2,v2CRN,'r*');hold on
        plot(tSMAP,vSMAP,'ko');hold on
        sensLSTM=sensSlope(v2LSTM,[t1:t2]','doPlot',1,'color','b');hold on
        sensCRN=sensSlope(v2CRN,[t1:t2]','doPlot',1,'color','r');hold off
        title(num2str(siteCRN(k).ID,'%04d'))
        legend(['LSTM ', num2str(sensLSTM.sen*365*1000,'%0.3f')],...
            ['CRN ', num2str(sensCRN.sen*365*1000,'%0.3f')])
        datetick('x','yy/mm')
        
        figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/L3/';
        saveas(f,[figFolder,num2str(siteCRN(k).ID,'%04d'),'.fig'])
        close(f)
    end
end
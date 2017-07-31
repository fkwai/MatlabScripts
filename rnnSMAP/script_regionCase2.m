
%% plot
global kPath
Alphabet=char('A'+(1:26)-1)';

%caseLst={'ABFL','ABGI','ABGL','ABHK','ACGK','ADFL','BKHL','GHIJ'};
caseLst={'ABFL','ABGL','BKHL','GHIJ'};
nCase=length(caseLst);

epoch=100;
for kCase=1:nCase
    hucLst=caseLst{kCase};

    hucIndLst=double(hucLst)-64;
    trainName=['huc',hucLst,'s4'];
    disp(hucLst)
    nHUC=12;
    for k=1:nHUC
        outName1=trainName;
        outName2=[trainName,'_oneModel'];
        outName3=[trainName,'_noModel'];
        testName=['huc',Alphabet(k),'s2'];
        
        [outTrain1,out1,covMethod1]=testRnnSMAP_readData(outName1,trainName,testName,epoch,'timeOpt',3);
        [outTrain2,out2,covMethod2]=testRnnSMAP_readData(outName2,trainName,testName,epoch,'varLst','varLst_oneModel','timeOpt',3);
        [outTrain3,out3,covMethod3]=testRnnSMAP_readData(outName3,trainName,testName,epoch,'varLst','varLst_noModel','timeOpt',3);
    end
end

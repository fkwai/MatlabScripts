
rootOut='E:\Kuai\rnnSMAP_outputs\hucv2nc2';
rootDB='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/';

jobHead='hucv2n2';
[outNameLst,dataNameLst,optTrainLst]=findJobHead(jobHead,rootOut);
optInit=initRnnOpt(2);
optLst=[];
for k=1:length(outNameLst)
    opt=optInit;
    opt.test=dataNameLst{k};
    opt.rootOut=rootOut;
    opt.rootDB=rootDB;
    optLst=[optLst;opt];    
end
optLst=optLst';
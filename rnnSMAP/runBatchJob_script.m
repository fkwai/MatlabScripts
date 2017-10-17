
rootOut='/mnt/sdb/rnnSMAP/output_SMAPgrid/';
rootDB='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/';

jobHead='hucv2n6';
[outNameLst,dataNameLst,optTrainLst]=findJobHead(jobHead,rootOut);
optInit=initRnnOpt(2);
optLst=optInit;
for k=1:length(outNameLst)
    opt=optInit;
    opt.test=dataNameLst{k};
    opt.rootOut=rootOut;
    opt.rootDB=rootDB;
    optLst(k)=opt;    
end
optLst=optLst';
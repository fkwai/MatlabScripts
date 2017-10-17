 

rootDir='/mnt/sdb/rnnSMAP/output_SMAPgrid/huc2n3_readyToDelete/';

dataName='hucv2n3010213';
epoch=300;
timeOpt=1;
out=postRnnSMAP_load([],dataName,epoch,timeOpt,'rootDir',rootDir);

ind=20050;
GLDASdir='Y:\Kuai\rnnSMAP\Database\tDB_soilM\';
SMAPdir='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
gH=csvread([GLDASdir,'\data\',sprintf('%06d',ind),'.csv']);
sH=csvread([SMAPdir,'\data\',sprintf('%06d',ind),'.csv']);
tInd=csvread([SMAPdir,'\tIndex.csv']);
tStr=num2str(tInd,'%8.2f');
tnum=datenum(tStr,'yyyymmdd.HH');
nt=length(tnum);

gH=gH/100;
sH(sH==-9999)=nan;
gDmat=reshape(gH,[8,nt/8]);
sDmat=reshape(sH,[8,nt/8]);
gD=nanmean(gDmat);
sD=nanmean(sDmat);
tnumD=tnum(1:8:end);
sum(isnan(sD))

plot(tnum,gH,'k-');hold on
plot(tnum,sH,'g*');hold on
plot(tnumD,gD,'b-o');hold on
plot(tnumD,sD,'ro');hold off

gHanom=gH-nanmean(gH);
sHanom=sH-nanmean(sH);
gDanom=gD-nanmean(gD);
sDanom=sD-nanmean(sD);
plot(tnum,gHanom,'k-');hold on
plot(tnum,sHanom,'g*');hold on
plot(tnumD,gDanom,'b-o');hold on
plot(tnumD,sDanom,'ro');hold off

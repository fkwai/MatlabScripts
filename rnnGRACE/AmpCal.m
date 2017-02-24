GRACEnormDir='E:\Kuai\rnnGRACE\data\gridTabGRACE_norm.csv';
GRACEDir='E:\Kuai\rnnGRACE\data\gridTabGRACE.csv';
GRACEnorm=csvread(GRACEnormDir);
GRACE=csvread(GRACEDir);

ampGRACE=zeros(size(GRACE,1),1);
for i=1:size(GRACE,1)    
    s=GRACE(i,1:96)';
    [maxAmp,f,scales,Amp,yI]=fftBandAmplitude(s,12,[2/3, 5/3]);
    ampGRACE(i)=maxAmp;
end

save ampGRACE ampGRACE
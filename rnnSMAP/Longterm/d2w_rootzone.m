function w = d2w_rootzone( d )
% calculate weight from depth, following SMAP val
% for example
% /coresite/coresiteinfo/16_ARS/refpix_16040906.txt
% d=[0.05,0.15,0.3]; w=[0.154,0.1923,0.654];
% /coresite/coresiteinfo/16_ARS/refpix_16030911.txt
% d=[0.05,0.25,0.45]; w=[0.207,0.276,0.517];

d=VectorDim(d,1);
d1=[0;d(1:end-1)];
d2=[d(2:end);1];
b1=(d+d1)/2;
b1(1)=0;
b2=(d+d2)/2;
ww=b2-b1;
w=ww./sum(ww);


end


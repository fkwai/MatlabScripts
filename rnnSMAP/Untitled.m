
data1=csvread('E:\Kuai\rnnSMAP\Database\Daily\CONUS\SMAP.csv');
data2=csvread('E:\Kuai\rnnSMAP\Database\Daily\CONUS\SMAP_Anomaly.csv');
data1(data1==-9999)=nan;
data2(data2==-9999)=nan;
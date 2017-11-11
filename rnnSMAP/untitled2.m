
file1='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/CONUS/ASNOW.csv';
file2='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/CONUS/ARAIN.csv';

d{1}=csvread(file1);
d{2}=csvread(file2);
d{1}(d{1}==-9999)=nan;
d{2}(d{2}==-9999)=nan;
d{3}=log(d{1}+1);

stat=zeros(4,3);
for k=1:3
    output=d{k};
	vecOutput=output(:);
	vecOutput(vecOutput==-9999)=[];
	perc=0;
	lb=prctile(vecOutput,perc);
	ub=prctile(vecOutput,100-perc);
	data80=vecOutput(vecOutput>=lb &vecOutput<=ub);
	m=mean(data80);
	sigma=std(data80);
	stat(:,k)=[lb;ub;m;sigma];
end

dd=d{2}(~isnan(d{2}));
A=dd(:);
alpha=0.1;
[mu,sigma]=normfit(A);
p1=normcdf(A,mu,sigma);
[H1,s1]=kstest(A,[A,p1],alpha)

mu=expfit(A,alpha);
p4=expcdf(A,mu);
[H4,s4]=kstest(A,[A,p4],alpha)
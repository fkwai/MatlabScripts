load('Y:\Kuai\rnnPAWS\F.mat')
perc=10;

for k=1:2
    if k==1
        S=F_Clinton_extensive;
    elseif k==2
        S=F_Clinton_simple;
    end
    nf=length(S)-1;
    mat=zeros(length(obs.t),nf);
    matNorm=zeros(length(obs.t),nf);
    stat=zeros(4,nf);
    for i=1:nf
        data=S(i).v;
        mat(:,i)=data;
        
        lb=prctile(data,perc);
        ub=prctile(data,100-perc);
        data80=data(data>=lb &data<=ub);
        m=mean(data80);
        sigma=std(data80);
        stat(:,i)=[lb,ub,m,sigma]';
        
        dataNorm=(data-lb)./(ub-lb)*2-1;
        matNorm(:,i)=dataNorm;
    end
    mat(isnan(mat))=-9999;
    dlmwrite(['train',num2str(k),'.csv'],mat,'precision',8);
    dlmwrite(['stat',num2str(k),'.csv'],stat,'precision',8);
    dlmwrite(['trainNorm',num2str(k),'.csv'],matNorm,'precision',8);
end

data=obs.v;
lb=prctile(data,perc);
ub=prctile(data,100-perc);
data80=data(data>=lb &data<=ub);
m=mean(data80);
sigma=std(data80);
stat=[lb,ub,m,sigma]';
dataNorm=(data-lb)./(ub-lb)*2-1;
dlmwrite('obs.csv',data,'precision',8);
dlmwrite('statObs.csv',stat,'precision',8);
dlmwrite('obsNorm.csv',dataNormk,'precision',8);

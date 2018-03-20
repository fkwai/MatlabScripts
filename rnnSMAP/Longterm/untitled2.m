

for k=1:size(LSTM.v,2)
    plot(LSTM.t,LSTM.v(:,k),'r-*');hold on
    plot(SMAP.t,SMAP.v(:,k),'ko');hold off
    xlim([datenumMulti(20150401,1),datenumMulti(20170401,1)])
    title(num2str(k))
end
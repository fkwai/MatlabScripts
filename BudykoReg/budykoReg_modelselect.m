mp={[2,0];[2,0.3]};

% Acfall={Acf;Acfy;Acfd48;Acfd72};
% Pcf2all={Pcf2;Pcfy2;Pcfd48_2;Pcfd72_2};
% Pcf3all={Pcf3;Pcfy3;Pcfd48_3;Pcfd72_3};

Acfall={Acf;Acfd48;Acfd72};
Pcf2all={Pcf2;Pcfd48_2;Pcfd72_2};
Pcf3all={Pcf3;Pcfd48_3;Pcfd72_3};

AICall=[];R2all=[];

for i=1:2
    modelp=mp{i};
    for j=1:3
        acf=Acfall{j};
        pcf2=Pcf2all{j};
        pcf3=Pcf3all{j};
        [Enew1,Ebudyko,R2,b,D,AIC]=budykoReg( E,Ep,P,Ampf,modelp,0);
        R2all=[R2all;R2];AICall=[AICall;AIC];
        [Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[acf],modelp,0);
        R2all=[R2all;R2];AICall=[AICall;AIC];
        [Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[acf,pcf2],modelp,0);
        R2all=[R2all;R2];AICall=[AICall;AIC];
        [Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[acf,pcf3],modelp,0);
        R2all=[R2all;R2];AICall=[AICall;AIC];
        [Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[acf,pcf2,pcf3],modelp,0);
        R2all=[R2all;R2];AICall=[AICall;AIC];
    end
end

RL=exp(min(AICall)-AICall)/2;

%top5 
[Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acf,Pcf3],[2,0],1)
[Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3],[2,0],1)
[Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acf,Pcf2,Pcf3],[2,0],1)
[Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3],[2,0.3],1)
[Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_3],[2,0],1)

function plotBasinBudget(HUC,t)

fields = {'P','Q','dS','Evp','err'}; % SWE

P = HUC.Rain+HUC.Snow;
E = HUC.Evp;
Q = HUC.Q';
dS= HUC.dS;
for i=1:length(fields)
    ff = fields{i};
    if strcmp(ff,'P') 
        v = P;
    elseif strcmp(ff,'err')
        dv = P - E - Q - dS; dv(isnan(dv)) = 0;
        v = cumsum(dv);
    else
        v = HUC.(ff);
    end
    ts(i).t = t;
    ts(i).v = v;
    plotTS(ts(i),getS(i,'l'));  hold on
end
hold off
legend(fields)
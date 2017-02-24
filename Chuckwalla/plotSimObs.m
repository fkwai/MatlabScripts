
% plot model simulation vs observation from PAWS. 
matfile='E:\Kuai\chuckwalla\Simulations\NRCSdata\Chuck_m.mat';
recfile='E:\Kuai\chuckwalla\Simulations\NRCSdata\Chuck_Rec.txt';

mat=load(matfile);
robj=mat.w.Rec.robj;
usgs=mat.w.tData.usgs;
rec=importdata(recfile);

figure
for j=1:4
    i=j+8;
    usgsind=j+5;
    sim.t = rec(:,1);
    sim.v = rec(:,i+1);
    sim = wDaily(sim);
    plotTS(sim,['-',getS(j,'l')]);hold on
    obs.v=usgs(usgsind).v./100;
    obs.t=usgs(usgsind).t;
    plotTS(obs,['--',getS(j,'l')]);hold on    
end
title('Ford Dry Lake soil moisture, sim vs obs')
legend('sim -2 in','obs -2 in',...
    'sim -4 in','obs -4 in',...
    'sim -8 in','obs -8 in',...
    'sim -20 in','obs -20 in')

figure
for j=1:4
    i=j+12;
    usgsind=j+9;
    sim.t = rec(:,1);
    sim.v = rec(:,i+1);
    sim = wDaily(sim);
    plotTS(sim,['-',getS(j,'l')]);hold on
    obs.v=usgs(usgsind).v./100;
    obs.t=usgs(usgsind).t;
    plotTS(obs,['--',getS(j,'l')]);hold on    
end
title('Desert Center Soil Moisture, sim vs obs')
legend('sim -2 in','obs -2 in',...
    'sim -4 in','obs -4 in',...
    'sim -8 in','obs -8 in',...
    'sim -20 in','obs -20 in')

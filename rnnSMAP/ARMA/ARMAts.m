function yp = ARMAts( x0,y0,x1,ns,varargin )
% train a ARMA model and forward it. 
% x0,y0: training set input and target
% x1: testing set input
% ns: number of step


pnames={'q'};
dflts={ns};
[q]=internal.stats.parseArgs(pnames, dflts, varargin{:});

p=ns;
d=0;
Mdl=arima(p,d,q);
EstMdl = estimate(Mdl,y0,'X',x0,'Y0',zeros(ns,1));
nx=size(x0,2);
nt=length(x1);
yp = forecast(EstMdl,nt,'Y0',zeros(ns,1),'X0',zeros(ns,nx),'XF',x1);

end


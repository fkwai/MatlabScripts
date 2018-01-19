function [ out ] = sensSlope( v,t,varargin)
% do sens slope

pnames={'doPlot','alpha','color'};
dflts={0,0.05,'k'};
[doPlot,alpha,plotColor]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

[taub tau h sig Z S sigma sen n senplot CIlower CIupper D Dall C3 nsigma]...
    =ktaub([t,v],alpha,doPlot,plotColor);
out=struct('taub',taub,'tau',tau,'h',h,'sig',sig,'Z',Z,'S',S,'sigma',sigma,'sen',sen,...
    'n',n,'senplot',senplot,'CIlower',CIlower,'CIupper',CIupper,'D',D,'Dall',Dall,'C3',C3,...
    'nsigma',nsigma);


end


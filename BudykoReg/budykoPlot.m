function budykoPlot(f, E, Ep, P,limx,limy,varargin)
%BUDYKOPLOT Summary of this function goes here
%   Detailed explanation goes here

set(0,'CurrentFigure',f(1))
hold on

x=Ep./P;
y=E./P;

if(length(varargin)==0)    
    plot(x,y,'*')
elseif(length(varargin)>0)
    if isstr(varargin{1})
        plot(x,y,varargin{1})
    else
        hold(f(2),'on');
        colv=varargin{1};
        titlestr=varargin{2};
        scatter(x,y,[],colv,'filled'); title(titlestr);
        colorbar; %caxis([0 40])
    end
end


hold on
xx=[0,1,max(x(~isinf(x)))];
yy=[0,1,1];
plot(xx,yy,'k','linewidth',2)
if isempty(limx)
    xlim([0,max(x(~isinf(x)))]);
else
    xlim(limx);
end
if isempty(limy)
    ylim([0,max(y(~isinf(y)))]);
else
    ylim(limy);
end
hold off

if isempty(limx)
    xlim([0,max(x(~isinf(x)))]);
    budykoCurve(f,max(x(~isinf(x))),'Budyko');
else
    budykoCurve(f,limx(2),'Budyko');
end

end


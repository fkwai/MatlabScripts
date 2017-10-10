function Rsq= RsqCalculate( x,y,varargin )
%Calculate R2 between two data set. x is regressed. y is object. 

noSq=0;
if ~isempty(varargin)
    noSq=varargin{1};
end

xx=x(~isnan(x)&~isnan(y));
yy=y(~isnan(x)&~isnan(y));
if ~isnan(xx) & ~isnan(yy)
    xx=VectorDim(xx,1);
    yy=VectorDim(yy,1);
    if noSq
        Rsq=corr(xx,yy);
    else
        Rsq=(corr(xx,yy))^2;
    end
else
    Rsq=nan;
end


end


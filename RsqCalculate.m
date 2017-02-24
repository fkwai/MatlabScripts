function Rsq= RsqCalculate( x,y )
%Calculate R2 between two data set. x is regressed. y is object. 

xx=x(~isnan(x)&~isnan(y));
yy=y(~isnan(x)&~isnan(y));
if ~isnan(xx) & ~isnan(yy)
    xx=VectorDim(xx,1);
    yy=VectorDim(yy,1);
    Rsq=(corr(xx,yy))^2;
else
    Rsq=nan;
end


end


function Rsq= RsqCalculate( x,y )
%Calculate R2 between two data set. x is regressed. y is object. 

x=VectorDim(x,1);
y=VectorDim(y,1);
xx=x(~isnan(x)&~isnan(y));
yy=y(~isnan(x)&~isnan(y));

Rsq=(corr(xx,yy))^2;


end


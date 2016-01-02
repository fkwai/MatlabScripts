function budykoCurve(f,maxvalue, ref)
%BUDYKO_CURVE Summary of this function goes here
%   Detailed explanation goes here

set(0,'CurrentFigure',f(1))
hold on

if strcmp(ref,'Budyko')
    fun=@(x)(x*tanh(1/x)*(1-exp(-x)))^0.5;
end

if strcmp(ref,'Pike')
    fun=@(x) 1/sqrt(1+(1/x)^2);
end

if(length(f)>1)
    hold(f(2),'on');
end
fplot(fun,[0,maxvalue],'Color','k')
xlabel('Ep / P')
ylabel('E / P')

hold off
end




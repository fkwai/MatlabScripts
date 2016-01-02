function rmse = turkPikeObj2(Params,Ep,P,E,varargin)
% Given a turk-pike parameter, find how it fits the observed E
%
doPlot = 0;
if length(varargin)>0 && ~isempty(varargin{1})
    doPlot = varargin{1};
end

X=Ep./P;
Ytp = turkPike2(X,Params);
Yobs=E./P;

rmse = sqrt(nanmean((Ytp-Yobs).^2));

%%
if doPlot
    figure
    fun= @(x)turkPike2(x,Params);
    fplot(fun,[Params(2),max(X)],'Color','k')
    hold on
    plot(X, Yobs, '*')
    title(['RMSE=',num2str(rmse),'; Params=',num2str(Params)])
    hold off
end
function plot121Line(varargin)
% (E) plot 1-to-1 line on gca
hold on
if length(varargin)>0
    s = varargin{1};
else
    s = 'b';
end
gca;
XL = get(gca,'XLim');
X = XL; Y=XL;
plot(X,Y,s,'LineWidth',2,'Color','k')
set(gca,'XLim',XL)
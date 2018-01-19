function ktau=sensPlotDat(dat,varargin)

if length(varargin)>0
    window = varargin{1};
else
    window = [];
end

field = 'TWSA';
ts.t = dat(:,1); 
if ts.t(1)>1e7, 
    for i=1:length(ts.t),
        ts.t(i)=datenum2(ts.t(i)); 
    end; 
end
ts.(field) = dat(:,2);
loc = isnan(ts.(field));
if ~isempty(window)
    loc = loc |(ts.t<window(1) | ts.t>window(2));
end
ts.(field)(loc)=[];
ts.t(loc)=[];
ktau = tauab_plot(ts,field); hold off
datetick('x')
xlabel('date (YY)')
ylabel('TWSA (mm)')
title(['slope=',num2str(ktau.sen),' [mm/month]'])

s = 20;
axisFont = s;
legFont = s;
titleFont = s;
xlabFont = s;
ylabFont = s;
h= gca;


set(h,'FontSize',axisFont);
%set(h,'LineWidth',3);
set(h,'Layer','top')
%set(h,'ticklength',[0.025 0.025])

hh = get(h,'Title');
set(hh,'FontSize',titleFont);
l = legend(h);
%legend('boxoff')
if ~isempty(l)
    set(l,'FontSize',legFont);
end
xl = get(h,'XLabel'); set(xl,'FontSize',xlabFont);
xl = get(h,'YLabel'); set(xl,'FontSize',ylabFont);
set(h,'ticklength',[0.015 0.025])
set(h,'LineWidth',2)

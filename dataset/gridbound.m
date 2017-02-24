function [x1,x2,y1,y2]=gridbound(lat,lon)
% calculate boundary coordinate of grid

xc=(lon(1:end-1)+lon(2:end))/2;
xleft=lon(1)-(xc(1)-lon(:,1));
xright=lon(end)+(lon(end)-xc(end));
x1=[xleft,xc];
x2=[xc,xright];

yc=(lat(1:end-1)+lat(2:end))/2;
ytop=lat(1)+(lat(1)-yc(1));
ybot=lat(end)-(yc(end)-lat(end));
y1=[ytop;yc];
y2=[yc;ybot];

end

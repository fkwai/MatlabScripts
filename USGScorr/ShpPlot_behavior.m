function [ Quad,f ] = ShpPlot_behavior( T,pT,S_I,varargin )
%WRITESHP_ERRMAP Summary of this function goes here
%   Detailed explanation goes here
% T: target lable of behavior. 1 - negative, 2 - positive
% pT: predict lable of behavior. 1 - negative, 2 - positive
% S_I: load(Y:\Kuai\USGSCorr\S_I.mat)
% Quad: quadrant of error map. pT=2 while T=1 - quad = 1;

USAshp='E:\work\DataAnaly\HUC\HUC4_main.shp';
if length(varargin)>0   %input a background map
    if(~isempty(varargin{1}))
        USAshp=varargin{1};
    end
end

Quad=zeros(length(T),1);

Quad(pT==2&T==1)=1;
Quad(pT==1&T==1)=2;
Quad(pT==1&T==2)=3;
Quad(pT==2&T==2)=4;

x=[S_I.X];
y=[S_I.Y];

f=figure;
if ~isempty(USAshp)
    shape=shaperead(USAshp);
    for i=1:length(shape)
        plot(shape(i).X,shape(i).Y,'-k');
        hold on
    end
end

plot(x,y,'go');hold on;   % for data selecting

p2=plot(x(Quad==2),y(Quad==2),'go');hold on    
p4=plot(x(Quad==4),y(Quad==4)','b*');hold on
p1=plot(x(Quad==3),y(Quad==3)','ro');hold on    
p3=plot(x(Quad==1),y(Quad==1)','r*');hold on
legend([p2(1),p4(1),p1(1),p3(1)],'pred F obs F','pred T obs T','pred T obs F','pred F obs T')
set(gcf,'position',get(0,'screensize'))
axis equal

end


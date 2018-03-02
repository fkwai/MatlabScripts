function w=voronoiRec(x,y,bb)

n=100;
xx=linspace(bb(1,1),bb(2,1),n);
yy=linspace(bb(1,2),bb(2,2),n);
[xm,ym]=meshgrid(xx,yy);

v=1:length(x);
w=zeros(length(x),1);
vp=griddata(x,y,v,xm,ym,'nearest');

for k=1:length(x)
    w(k)=sum(vp(:)==k)./n^2;
end

end


folder='Y:\Kuai\rnnSMAP\test\';
par=csvread([folder,'para.csv']);
xData=csvread([folder,'x.csv']);
yData=csvread([folder,'y.csv']);

nh=4;
nb=3;
nx=2;
nt=5;
ny=1;

n1=nh*nx;
n1c=nh;
n2=nh*nh;
n2c=nh;
n3=nh*ny;
n3c=ny;


m1=reshape(par(1:nh*nx),[nx,nh])';
m1c=par(nh*nx+1:nh*nx+nh);
m2=reshape(par(nh*nx+nh+1:nh*nx+nh+nh*nh),[nh,nh])';
m2c=par(nh*nx+1:nh*nx+nh);


x1=reshape(x(1,:,:),[3,2]);
x0=zeros(5,1);
m2*x0+m2c+m1*x1'+m1c

% m1=[ 0.1520 -0.3525
% -0.4856 -0.5722
%  0.3472  0.0818];
% m1c=[ 0.5488
% -0.5783
%  0.6013];
% m2=[-0.5620  0.4550  0.5659
% -0.5407  0.2686  0.1466
% -0.4959 -0.0946  0.0562];
% m2c=[-0.0820
%  0.5750
%  0.1659];
% 
% a=[3;2];
% a0=[0;0;0];

m2*a0+m2c+m1*a+m1c

m2*(m2*a0+m2c+m1*a+m1c)+m2c+m1*a+m1c

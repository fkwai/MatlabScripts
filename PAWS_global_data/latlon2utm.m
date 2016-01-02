function [E, N] = latlon2utm(lat, lon, varargin)
% convert lat & lon to UTM coordinates
% input: lat & lon in decimal degrees
% output: E & N in m
if isempty(varargin)
    lon0 = cmz(lon);
else
    lon0 = varargin{1};
end

if length(varargin)>1
    hs=varargin{2}; %'N' or 'S'
else
    hs='N';
end
    
lat = lat*pi/180;   % convert to radians
lon = lon*pi/180;
lon0 = lon0*pi/180;
a = 6378137;        % equatorial radius, m
b = 6356752.3142;   % polar radius, m
f = 1/298.257223563;% flatting
k0 = 0.9996;
e = sqrt(1-b^2/a^2);
ep2 = (e*a/b)^2;
n = (a-b)/(a+b);
rho = a*(1-e^2)/(1-e^2*sin(lat)^2)^(3/2);
nu = a/(1-e^2*sin(lat)^2)^(1/2);
p = lon - lon0;
M = a*((1-e^2/4-3*e^4/64-5*e^6/256)*lat-(3*e^2/8+3*e^4/32+45*e^6/1024)*sin(2*lat)...
    +(15*e^4/256+45*e^6/1024)*sin(4*lat)-35*e^6/3072*sin(6*lat));
% Ap = a*(1-n+5/4*(n^2-n^3)+81/64*(n^4-n^5));
% S0 = Ap*lat;
% S = S0;
% error = 1e6;
% iter = 0;
% while error > 0.01
%     Bp = 3*tan(S)/2*(1-n+7/8*(n^2-n^3)+55/64*(n^4-n^5));
%     Cp = 15*tan(S)^2/16*(1-n+3/4*(n^2-n^3));
%     Dp = 35*tan(S)^3/48*(1-n+11/16*(n^2-n^3));
%     Ep = 315*tan(S)^4/512*(1-n);
%     S = Ap*lat - Bp*sin(2*lat) + Cp*sin(4*lat) - Dp*sin(6*lat) + Ep*sin(8*lat);
%     error = abs(S - S0);
%     S0 = S;
%     iter = iter + 1;
% end

k1 = M*k0;
k2 = k0*nu*sin(lat)*cos(lat)/2;
k3 = k0*nu*sin(lat)*cos(lat)^3/24*(5-tan(lat)^2+9*ep2*cos(lat)^2+4*ep2^2*cos(lat)^4);
N = k1 + k2*p^2 + k3*p^4;
k4 = k0*nu*cos(lat);
k5 = k0*nu*cos(lat)^3/6*(1-tan(lat)^2+ep2*cos(lat)^2);
E = k4*p + k5*p^3 + 500000;

if  strcmp(hs,'S')
    N=N+1e7;
end
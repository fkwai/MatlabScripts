function d2= linearIntp( d,r1,r2 )
%LINEARINTP Summary of this function goes here
%   Detailed explanation goes here

% range r1 has been linearly mapped to r2
% so what will be the value of d?
d2 = (r2(2)-r2(1))*(d - r1(1))/(r1(2)-r1(1))+r2(1);

end

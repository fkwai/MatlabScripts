function d = ceomday(y,m)
% m should be 1:12
%Cumulative EOMDAY End of month.
% Chaopeng: fast for determining jd
cdpm=[31,59,90,120,151,181,212,243,273,304,334,365]';
m = 1:max(m);
d = y - m;
d(:) = cdpm(m);
loc = ((rem(y,4) == 0 & rem(y,100) ~= 0) & m>=2);
if rem(y,400)==0, loc(m>=2)=1; end
d(loc)=d(loc)+1;


% a correction: 2000 is a leap year
% However, some exceptions to this rule are required since the duration of
% a solar year is slightly less than 365.25 days. Years that are evenly 
%divisible by 100 are not leap years, unless they are also evenly 
% divisible by 400, in which case they are leap years.[1][2] 
%For example, 1600 and 2000 were leap years, but 1700, 1800 and 1900 
%were not. Similarly, 2100, 2200, 2300, 2500, 2600, 2700, 2900, and 
% 3000 will not be leap years, but 2400 and 2800 will be.
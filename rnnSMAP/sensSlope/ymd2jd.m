function [d,YJD]=ymd2jd(dd,option) 
% YJD normally means Julian day in a year
% option=0, input yyyyjul,output yyyymmdd (string) & jd (num)
% option=1, input yyyymmdd, output yyyyjul & jd
% option=2, input MATLAB datenum, output yyyyjul &  jd
% option=3, input dd=[y m d] or yyyymmdd, output jd & yyyymmdd
% option=4, input dd=[y jd], output [y m d] and yyyymmdd
% option=5, input MATLAB datenum, output yyyymmdd &  [y m d]
% datenum2 calls this function
switch option
    case 0
        year = floor(dd/1000);
        start = datenum(num2str(year*10000+101),'yyyymmdd');
        str=num2str(dd);
        days=str2num(str(end-2:end));
        day = start+days-1;
        d=num2str(datestr(day,'yyyymmdd'));
        YJD = days;
    case 1
        year = floor(dd/10000);
        start = datenum(num2str(year*10000+101),'yyyymmdd');
        curr = datenum(num2str(dd),'yyyymmdd');
        YJD = curr - start + 1;
        d=year*1000+YJD;
    case 2
        year = str2num(datestr(dd,'yyyy'));
        start = datenum(num2str(year*10000+101),'yyyymmdd');
        YJD = dd - start + 1;
        d=year*1000+YJD;
    case 3
        if length(dd)==3
            y = dd(1); m=dd(2); day=dd(3);
        elseif length(dd)==1
            y = floor(dd/10000);
            m = floor((dd - y*1e4)/1e2);
            day = dd - y*1e4 - m*1e2;
        end
        ceomd = ceomday(y,1:12); % use cumulative end of month day function. Chaopeng
        if m>1
            d = ceomd(m-1)+day;
        else
            d = day;
        end
        YJD = y;
    case 4
        y = dd(1); jd = dd(2);
        ceomd = ceomday(y,1:12);
        m = find(ceomd >= jd,1);
        if m >1
            day = jd - ceomd(m-1);
        else
            day = jd;
        end
        d = [y m day];
        YJD = y*1e4+m*1e2+day;
    case 5
        ymd = datestr(dd,'yyyymmdd'); d = str2num(ymd);
        YJD = [str2num(ymd(1:4)), str2num(ymd(5:6)), str2num(ymd(7:8))]; 
end


%{
[d,YJD]=ymd2jd(1997151,0)

d =

19970531


YJD =

   151

[d]=ymd2jd(19970531,1)

d =

     1997151

[d,YJD]=ymd2jd(19970531,1)

d =

     1997151


YJD =

   151

[d,YJD]=ymd2jd(datenum2(19970531),2)

d =

     1997151


YJD =

   151

[d,YJD]=ymd2jd([1997 05 31],3)

d =

   151


YJD =

    19970531

[d,YJD]=ymd2jd([1997 151],4)

d =

        1997           5          31


YJD =

    19970531

[d,YJD]=ymd2jd(datenum2(19970531),5)

d =

    19970531


YJD =

        1997           5          31


%}
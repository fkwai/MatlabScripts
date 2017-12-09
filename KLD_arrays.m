function [KL,xx]=KLD_arrays(A,B,xEnds,varargin)
% Calculate Kullback_Leibler divergence for empirical data
% A has data for P, and B has data for Q
% KL evaluates how much information is lost when Q is used to approximate P
% (second argument approximates the first)
% A and B are arrays of sampled values
% opt ==
% (1, default) a small-value smoother,as suggested by 
% (2) throwing them away vs smoothing the distribution.
% xEnds (may be []) is an array of coordinates
% It is only needed for certain opt.
% [xEnds(1),xEnds(2)] forms the first bin, [xEnds(2),xEnds(3)] forms the
% second bin, and so forth
% we count the number of instances within these bins and divide by bin
% width to get empirical pdf
% for bins with zero count. it is a deep issue with KL_D, so there are two
% treatment
% http://web.engr.illinois.edu/~hanj/cs412/bk3/KL-divergence.pdf
% i
opt = 1;
% the last bin absorbs values?
absorb=1;
eps = 1e-5; 
if length(varargin)>0
    opt = varargin{1};
end
xx=[]; KL=[];

if absorb && ~isempty(xEnds)
    A(A<xEnds(1))=xEnds(1);
    A(A>xEnds(end))=xEnds(end);
    
    B(B<xEnds(1))=xEnds(1);
    B(B>xEnds(end))=xEnds(end);
end

[fA,xA] = ecdf(A);
[C,ia,ic] = unique(A);
[fB,xB] = ecdf(B);

switch opt
    case 1
        % interpolate ecdfs
        % smooth 0 bins with a small value
        [xA,fA] = mergeUniqueLastX(xA,fA);
        [xB,fB] = mergeUniqueLastX(xB,fB);
        yLa = interp1(xA,fA,xEnds,'pchip',0); 
        yLa(xEnds<xA(1))=0;yLa(xEnds>xA(end))=1;
        yLb = interp1(xB,fB,xEnds,'pchip',0);
        yLb(xEnds<xB(1))=0;yLb(xEnds>xB(end))=1;
        D   = xEnds(2:end)-xEnds(1:end-1);
        xx  = (xEnds(1:end-1)+xEnds(2:end))/2;
        Pp  = (yLa(2:end)-yLa(1:end-1));
        Pq  = (yLb(2:end)-yLb(1:end-1));
        pVect1  = nudgeZeroEps(Pp,eps);
        pVect2  = nudgeZeroEps(Pq,eps);
        
        KL = sum(pVect1 .* (log2(pVect1)-log2(pVect2)));
    otherwise
        error(['KLD_arrays:: opt ', num2str(opt),' not implemented yet'])
end
4;
%[fA,xA] = ecdf(A);

function y = nudgeZeroEps(y,eps)
% nudge a eps value into 0
n0 = sum(y<=0);
n1 = sum(y>0); 
loc = y<=0;
added= n0*eps;
av = added/n1;
y(loc)=eps;
y(~loc)=y(~loc)-av;

function [x,y]=mergeUniqueLastX(x,y)
% merge unique y and only keep the last occurrence
% x is indexed for convenience
[x,ia,ic] = unique(x,'last');
y = y(ia);
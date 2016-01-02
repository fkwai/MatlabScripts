function [Y] = turkPike2(X,Params)
v = Params(1);
phi = Params(2);
Y = (1+(X-phi).^(-v)).^(-1/v);


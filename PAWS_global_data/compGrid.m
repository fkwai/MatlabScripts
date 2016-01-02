function [ output_args ] = compGrid( r1, r2 )
%COMPGRID Summary of this function goes here
%   find out if two grid are of same cellsize, x/y corner, num of
%   row/col... input raster are of format of Env.OBJ.rGrid

c(1)=r1.col==r2.col;
c(2)=r1.row==r2.row;
c(3)=r1.xllcorner==r2.xllcorner;
r1.yllcorner=r2.yllcorner;
r1.




end


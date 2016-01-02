function lon0 = cmz(lon)
% calculate the central meridian of zone

lon0 = floor(lon/6)*6+3;
if lon0 > 180
    lon0 = lon0 - 6;
end

end
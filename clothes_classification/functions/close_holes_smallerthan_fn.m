function bw = close_holes_smallerthan_fn( original, areat )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
filled = imfill(original, 'holes');
holes = filled & ~original;
bigholes = bwareaopen(holes, areat);
smallholes = holes & ~bigholes;
bw = original | smallholes;

end


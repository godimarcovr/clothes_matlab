function [ patches ] = ext_patches_mask( img, mask, prows, pcols, stride )
%EXT_PATCHES_MASK extracts patches from an image that are in a mask
%   Detailed explanation goes here

%prendo la bounding box per ridurre i tempi di calcolo!
rprops = regionprops(mask,'Image','BoundingBox','Area');
[~,index] = max([rprops.Area]);
mask = rprops(index).Image;
bbcoords = rprops(index).BoundingBox;
img = img(ceil(bbcoords(2)):ceil(bbcoords(2))+bbcoords(4)-1,ceil(bbcoords(1)):ceil(bbcoords(1))+bbcoords(3)-1,:);

patches = [];
[rows,cols,ch]=size(img);
Z = zeros(rows,cols);
mask = double(mask);
num_p = 0;

% figure;
for col = 1:stride:cols
    lim_c = col+pcols-1;
   % fprintf('%i|%i\n',col,cols);
    if lim_c>cols; continue; end
  for row = 1:stride:rows
      lim_r = row+prows-1;
      if lim_r>rows; continue; end
      Z=Z.*0;
      ev = Z;
      rcoords = row:lim_r;
      ccoords = col:lim_c;
      Z(rcoords,ccoords)=1;
      ev = Z+mask;
      good = ev==2;
%       imagesc(ev); colorbar; pause(0.2); drawnow;
      if sum(good(:))== prows*pcols;
%           fprintf('trovata!!!\n');
          num_p = num_p +1;
          patches{num_p}.img = img(rcoords, ccoords,:);
          patches{num_p}.coords = find(good);
      end
  end
end
end


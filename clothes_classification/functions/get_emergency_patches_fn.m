function features = get_emergency_patches_fn( img, num_patches, num_colors, patch_rows, patch_cols, color_mode )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
num_attempts_per_patch = 3;
acceptability_threshold = 0.9;

mask = maschera_binaria_fn(img);

rprops = regionprops(mask,'Image','BoundingBox','Area');
[~,index] = max([rprops.Area]);
bbimg = rprops(index).Image;
bbimgcoords = rprops(index).BoundingBox;

if strcmp(color_mode,'460')
    color_dim = 1;
elseif strcmp(color_mode,'rgb')
    color_dim = 3;
elseif strcmp(color_mode,'cielab')
    color_dim = 3;
end

featurelen = (color_dim*num_colors+28);
features = zeros(1,featurelen*num_patches);
if size(bbimg,1)<patch_rows || size(bbimg,2)<patch_cols
    return
end

count = 0;

for att=1:(num_attempts_per_patch*num_patches)
    tlr = randi(size(bbimg,1)-patch_rows+1)+randi(size(bbimg,1)-patch_rows+1);
    tlr = floor(tlr/2);
    tlc = randi(size(bbimg,2)-patch_cols+1)+randi(size(bbimg,2)-patch_cols+1);
    tlc = floor(tlc/2);
    tmp=bbimg(tlr:tlr+patch_rows-1,tlc:tlc+patch_cols-1);
    tmp=sum(tmp(:));
    if tmp >= (patch_rows*patch_cols)*acceptability_threshold
        patch.img = img(floor(bbimgcoords(2))-1+tlr:floor(bbimgcoords(2))-1+tlr+patch_rows-1,floor(bbimgcoords(1))-1+tlc:floor(bbimgcoords(1))-1+tlc+patch_cols-1,:);
        features((featurelen*count)+1:(featurelen*(count+1))) = ...
                            extract_complete_features_from_patches_fn( {patch}, patch_rows, patch_cols,0,0,num_colors,1, color_mode );
        count = count + 1;
        if count == num_patches
            return
        end
    end
end

if count>0
    fprintf('Non sono riuscito a trovare fuori abbastanza patch!\n');
    features((featurelen*count)+1:end) = repmat(features(1:featurelen),1,num_patches-count);
end


end


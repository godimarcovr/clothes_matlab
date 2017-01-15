function ctfeat_vect = get_color_text_features_simple_fn( img_name, dim_img, patch_rows, patch_cols,uniforme_ent_tresh,texthresh,num_colors,num_patches, color_mode )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
%impostazioni colore
color_dim = 1;
if strcmp(color_mode,'460')
    color_dim = 1;
elseif strcmp(color_mode,'rgb')
    color_dim = 3;
elseif strcmp(color_mode,'cielab')
    color_dim = 3;
end

single_patch_dim = (color_dim*num_colors+28);

%leggo immagine
img = imresize(imread(img_name),dim_img);

%inizializzo il vettore che ritornerò
% ctfeat_vect = zeros(1,single_patch_dim * num_patches);
ctfeat_vect = [];

patches = random_patch_sample_fn( img, patch_rows, patch_cols, num_patches );

for i=1:length(patches)
    ctfeat_vect = [ctfeat_vect extract_complete_features_from_patches_fn( patches(i), patch_rows...
                                                        , patch_cols,uniforme_ent_tresh,texthresh,num_colors,1, color_mode)];
end


end


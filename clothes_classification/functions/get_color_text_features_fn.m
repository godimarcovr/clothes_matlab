function ctfeat_vect = get_color_text_features_fn( img_name,mode, dim_img, patch_rows, patch_cols, patch_stride,uniforme_ent_tresh,texthresh,num_colors,num_patches, color_mode )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
    
    %numero di patch che prendo in più per ricavare informazioni più
    %significative
    overpatch_factor = 3;
    num_patches_original = num_patches;
    num_patches = num_patches * overpatch_factor;
    %indici delle patch che considero texturate
    textured_indices = zeros(1,0);
    %percentuale di patch che voglio textured
    textured_perc = 0.5;
    textured_num = ceil(num_patches_original * textured_perc);
    
    color_dim = 1;
    
    %impostazioni colore
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
    %ricavo patch nella maschera binaria (cell array di struct .img è
    %immagine e .coords le coordinate)
    patches = ext_patches_mask( img, maschera_binaria_fn(img), patch_rows, patch_cols, patch_stride );
    
    ctfeat_vect = zeros(1,single_patch_dim * num_patches);
%     fprintf('Patch trovate: %i \n', size(patches,2));
    if size(patches,2) == 0
        ctfeat_vect(:) = get_emergency_patches_fn( img, num_patches, num_colors, patch_rows, patch_cols, color_mode );
    elseif strcmp(mode,'randomsample')
        ctfeatures = [];
        count = 0;
        while count<num_patches && size(patches,2)>0
            while isempty(ctfeatures) && size(patches,2)>0
                ctfeat_ind = randsample(1:size(patches,2),1);
                ctfeatures = extract_complete_features_from_patches_fn( patches(ctfeat_ind), patch_rows...
                                                        , patch_cols,uniforme_ent_tresh,texthresh,num_colors,0, color_mode);
                patches = patches([1:ctfeat_ind-1, ctfeat_ind+1:end]);
            end
            %se arriva qua empty vuol dire che non ci sono più patch
            if isempty(ctfeatures)
                ctfeat_vect(((single_patch_dim*count)+1):end) = ...
                        get_emergency_patches_fn( img, (num_patches-count), num_colors, patch_rows, patch_cols, color_mode );
                %fprintf('%s non ha altre %i patch utilizzabili!\n',img_name,(num_patches-count));
            else
                ctfeat_vect(((single_patch_dim*count)+1):(single_patch_dim*(count+1))) = ctfeatures(1,:);
                count = count + 1;
                
                
                % controllo se è textured, nel caso me la segno
                rf = ctfeatures(num_colors+1);
                if rf > texthresh
                    textured_indices = [textured_indices count];
                end
                
                ctfeatures = [];
            end 
        end
        
    else
        fprintf('modalità errata!\n')
        return
    end
    
    %seleziono qua le patch che tengo
    ctfeat_vect2 = ctfeat_vect;
    ctfeat_vect = zeros(1,single_patch_dim * num_patches_original);
    untextured_indices = 1:num_patches;
    untextured_indices(textured_indices) = [];
    textured_indices = randsample(textured_indices,min(length(textured_indices),textured_num));
    untextured_num = num_patches_original - length(textured_indices);
    
    patch_inserite = 0;
    for tind=textured_indices
        count = tind-1;
        ctfeat_vect(((single_patch_dim*patch_inserite)+1):(single_patch_dim*(patch_inserite+1))) = ctfeat_vect2(((single_patch_dim*count)+1):(single_patch_dim*(count+1)));
        patch_inserite = patch_inserite + 1;
    end
    
    if length(untextured_indices) < untextured_num
        untextured_indices = [untextured_indices randsample(1:num_patches,untextured_num - length(untextured_indices))];
    end
    
    for utind=untextured_indices(1:untextured_num)
        count = utind-1;
        ctfeat_vect(((single_patch_dim*patch_inserite)+1):(single_patch_dim*(patch_inserite+1))) = ctfeat_vect2(((single_patch_dim*count)+1):(single_patch_dim*(count+1)));
        patch_inserite = patch_inserite + 1;
    end
    
    if size(ctfeat_vect,2) > single_patch_dim*num_patches_original
        fprintf('asd');
    end
    
end


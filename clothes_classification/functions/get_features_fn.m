function [feat_vector,mins,maxes] = get_features_fn( dataset_info , modes, dim_img, img_resize_factor,uniforme_ent_tresh,texthresh, patch_rows, patch_cols, patch_stride,minsmaxes )
%get_features_fn Calcola vettore di features, ritorna le features in riga
%  dataset_info : cell array of structs with relevant info
%  mode : che features utilizzare (shape, shape_col_text, ...)
%  dim_img : vettore delle dimensioni dell'immagine che mi aspetto
%  (ridimensiono)
%  img_resize_factor : fattore di riduzione per calcolo maschera binaria

dim_maschera = imresize(zeros(dim_img),img_resize_factor);
dim_maschera = size(dim_maschera(:),1);
quantization_levels = 0;

feat_vector = [];

for modeind=1:length(modes)
    mode = modes{modeind};
    if strcmp(mode{1},'shape')
        feat_vector = [feat_vector, get_shape_features_fn( dataset_info,dim_img, img_resize_factor )];
    elseif strcmp(mode{1},'color_text')
        %devo distinguere modalità di campionamento (random, più freq ecc) e
        %modalità di aumento (più valori per colore o più patch, oppure ripeto
        %ecc
        fprintf('Inizio calcolo feature colore/texture \n');
        num_patches = mode{2};
        num_colors = mode{3};
        color_mode = mode{4};
        if strcmp(color_mode,'460')
            color_dim = 1;
        elseif strcmp(color_mode,'rgb')
            color_dim = 3;
        elseif strcmp(color_mode,'cielab')
            color_dim = 3;
        end
        savefilename = strcat('color_text_cache_',num2str(num_colors),'_',num2str(num_patches),'_',color_mode,'.mat');
        if exist(savefilename,'file')
            load(savefilename);
%             ct_feat_vector = ct_feat_vector(:,1:5);
        else
            
            ct_feat_vector = zeros(size(dataset_info,1),(color_dim*num_colors+28)*num_patches);
            parfor i=1:size(dataset_info,1)
                if mod(i,100)==0
                    fprintf('Immagine numero %i\n',i);
                end
                img_name = dataset_info{i}.filename;
                color_texture_feat_vector = get_color_text_features_fn(img_name ,'randomsample', dim_img, patch_rows, patch_cols, patch_stride,...
                                                    uniforme_ent_tresh,texthresh,num_colors,num_patches, color_mode );
%                 if (num_colors+28)*num_patches ~= size(color_texture_feat_vector,2)
%                     size(color_texture_feat_vector,2)
%                 end
                ct_feat_vector(i,:) = color_texture_feat_vector;
            end
            save(savefilename,'ct_feat_vector');
        end
        feat_vector = [feat_vector, ct_feat_vector];
        
        fprintf('Fine calcolo feature colore/texture \n');
        
    elseif strcmp(mode{1},'shapeprops')
        fprintf('Inizio calcolo region props \n');
        microdim = mode{2};
        savefilename = strcat('shapeprops_cache_',num2str(microdim),'.mat');
        if exist(savefilename,'file')
            load(savefilename);
        else
            rp_feat_vector = zeros(size(dataset_info,1),3+microdim(1)*microdim(2));
            parfor i=1:size(dataset_info,1)
                if mod(i,100)==0
                    fprintf('Immagine numero %i\n',i);
                end
                img_name = dataset_info{i}.filename;
                rp_feat_vector(i,:) = get_region_props_fn(img_name,dim_img,microdim);
            end
            save(savefilename,'rp_feat_vector');
        end
        feat_vector = [feat_vector, rp_feat_vector];
        
        fprintf('Fine calcolo region props \n');
    elseif strcmp(mode{1},'global_color')
        fprintf('Inizio calcolo global color \n');
        num_colors = mode{2};
        colorspace = mode{3};
        savefilename = strcat('global_color_cache_',num2str(num_colors),'_',colorspace,'.mat');
        if exist(savefilename,'file')
            load(savefilename);
        else
            gc_feat_vector = zeros(size(dataset_info,1),3*num_colors);
            for i=1:size(dataset_info,1)
                if mod(i,100)==0
                    fprintf('Immagine numero %i\n',i);
                end
                img_name = dataset_info{i}.filename;
                gc_feat_vector(i,:) = global_color_fn( img_name,dim_img, num_colors, colorspace );
            end
            save(savefilename,'gc_feat_vector');
        end
        feat_vector = [feat_vector, gc_feat_vector];
        fprintf('Fine calcolo global color \n');
    else
        fprintf('modalità errata!\n')
        return
    end
end

%recupero massimi e minimi
if length(minsmaxes) == 1
    mins = min(feat_vector);
    maxes = max(feat_vector);
else
    mins = minsmaxes(1,:);
    maxes = minsmaxes(2,:);
end

%normalizzo a [0.0 1.0]
minmat = repmat(mins,size(feat_vector,1),1);
rangemat = repmat( maxes - mins,size(feat_vector,1),1);
feat_vector2 = (feat_vector - minmat) ./ rangemat;
feat_vector2(isnan(feat_vector2)) = feat_vector(isnan(feat_vector2));
feat_vector = feat_vector2;

% %calcolo correlazione RFILT/GLCM e entropy/GLCM
% ct_feat_vector = feat_vector(:,end-27:end);
% rfilt_glcm_products = repmat(ct_feat_vector(:,1),1,27).*ct_feat_vector(:,2:end);
% mean_rfilt = mean(ct_feat_vector(:,1));
% means_glcm = mean(ct_feat_vector(:,2:end));
% covs = mean(rfilt_glcm_products) - mean_rfilt*means_glcm;
% corrs = covs ./ (std(ct_feat_vector(:,1)) ./ std(ct_feat_vector(:,2:end)));


%quantizzo a quantization_levels livelli
if quantization_levels > 0
    feat_vector = floor(feat_vector.*(quantization_levels-1))+1;
    feat_vector(feat_vector > quantization_levels) = quantization_levels;
    feat_vector(feat_vector < 1) = 1;
end

%incremento artificiale dell'importanza delle patch
% feat_vector = [ feat_vector repmat(feat_vector(:,end-30:end),1,10) ];


end


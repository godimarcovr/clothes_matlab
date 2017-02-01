function [ aug_features, aug_categories, nninfo ] = data_augment_fn( features, categories, featlist )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%% settings
color_text_multiplier_cap = 15;

aug_features = features;
aug_categories = categories;

cursor = 1;

nninfo = {};

for modeind=1:length(featlist)
    modalita = featlist{modeind};
    if strcmp(modalita{1},'shapeprops')
        microdim = modalita{2};
        cursor = cursor + 3;
        new_masks = zeros( size(aug_features,1), microdim(1) * microdim(2));
        for i=1:size(aug_features,1)
            mask = aug_features(i, cursor:cursor + microdim(1) * microdim(2) - 1);
            mask = reshape(mask,microdim);
            mask = flip(mask,2);
            new_masks(i,:) = mask(:);
        end
        new_features = aug_features;
        new_features(:, cursor:cursor + microdim(1) * microdim(2) - 1) = new_masks;
        aug_features = [aug_features; new_features];
        aug_categories = [aug_categories; aug_categories];
        
        nninfo = {nninfo {}};
        nninfo{end}.size = microdim;
        nninfo{end}.range_start = cursor;
        nninfo{end}.range_end = cursor + microdim(1) * microdim(2) - 1;
        cursor = cursor + microdim(1) * microdim(2);
    elseif strcmp(modalita{1},'global_color')
        num_colors = modalita{2};
        colorspace = modalita{3};
        %dovrebbe essere sempre 3 per colore
        cursor = cursor + num_colors * 3;
    elseif strcmp(modalita{1},'color_text')
        num_patches = modalita{2};
        num_colors = modalita{3};
        color_mode = modalita{4};
        version = modalita{5};
        color_text_grid_dim = modalita{6};
        color_text_grid_rows = color_text_grid_dim(1);
        color_text_grid_cols = color_text_grid_dim(2);
        if strcmp(color_mode,'460')
            color_dim = 1;
        elseif strcmp(color_mode,'rgb')
            color_dim = 3;
        elseif strcmp(color_mode,'cielab')
            color_dim = 3;
        end
        
        single_patch_dim = (color_dim*num_colors+28);
        % per una singola area: base in cui esprimo la permutazione
        num_permutations = factorial(num_patches);
        %numero cifre del numero nella nuova base
        num_areas = color_text_grid_rows * color_text_grid_cols;
        
        permutations = perms(1:num_patches);
        new_patches = [];
        
        % quante combinazioni per ciascuna area per num_areas aree
        
        %for permut_number=0:((num_permutations^num_areas)-1)
        permut_numbers = randsample(num_permutations^num_areas,color_text_multiplier_cap);
        for permut_number=permut_numbers'
            permut_number = permut_number - 1;
            %punta al primo valore della prima area
            areas_cursor = cursor;
            permut_str = dec2base(permut_number, num_permutations, num_areas);
            new_comb = [];
            for digitch=permut_str
                id_perm = base2dec(digitch,num_permutations);
                perm = permutations(id_perm+1,:);
                for j=perm
                    new_comb = [new_comb, aug_features(:,areas_cursor+(j-1)*single_patch_dim:areas_cursor-1+j*single_patch_dim)];
                end
                areas_cursor = areas_cursor + num_patches * single_patch_dim;
            end
            new_patches = [new_patches; new_comb];
        end
        
        
% % % % %         permutations = perms(1:num_patches);
% % % % %         new_patches = zeros(size(aug_features,1) * num_permutations, single_patch_dim * num_patches);
% % % % %         for i=1:num_permutations
% % % % %             for j=permutations(i,:)
% % % % %                 new_patches(((i-1)*size(aug_features,1))+1:(i*size(aug_features,1)),((j-1)*single_patch_dim)+1:j*single_patch_dim) = ...
% % % % %                                 aug_features(:,cursor+(j-1)*single_patch_dim:cursor-1+j*single_patch_dim);
% % % % %             end
% % % % %         end
%         new_features = repmat(aug_features,num_permutations^num_areas,1);
%         new_features(:, cursor:cursor+(num_patches*num_areas*single_patch_dim)-1) = new_patches;
%         aug_features = new_features;
%         aug_categories = repmat(aug_categories, num_permutations^num_areas,1);
%         cursor = cursor + ((num_permutations^num_areas)*single_patch_dim);
        
        new_features = repmat(aug_features,color_text_multiplier_cap,1);
        new_features(:, cursor:cursor+(num_patches*num_areas*single_patch_dim)-1) = new_patches;
        aug_features = new_features;
        aug_categories = repmat(aug_categories, color_text_multiplier_cap,1);
        cursor = cursor + num_patches*num_areas*single_patch_dim;
        
    end
end
    
end


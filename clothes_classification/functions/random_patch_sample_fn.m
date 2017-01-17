function [ patches_grid ] = random_patch_sample_fn( img, prows, pcols, num_patches, grid_rows, grid_cols )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%Settings
max_attempts_per_patch = 4;
max_attempts = max_attempts_per_patch * num_patches;
acceptability_threshold = 0.9;


patches_grid = cell(1,num_patches*grid_rows*grid_cols);

%faccio bounding box e restringo immagine e maschera lì
mask = maschera_binaria_fn(img);
rprops = regionprops(mask,'Image','BoundingBox','Area');
[~,index] = max([rprops.Area]);
mask_grid = rprops(index).Image;
bbcoords = rprops(index).BoundingBox;
img_grid = img(ceil(bbcoords(2)):ceil(bbcoords(2))+bbcoords(4)-1,ceil(bbcoords(1)):ceil(bbcoords(1))+bbcoords(3)-1,:);

celldim = [ floor(size(img_grid,1)/grid_rows), floor(size(img_grid,2)/grid_cols) ];
if (celldim(1) < prows) || (celldim(2) < pcols)
    fprintf('La griglia è troppo piccola per estrarre patch al suo interno!\n');
    if grid_rows == 1 && grid_cols == 1
        fprintf('Anzi, addirittura limmagine intera è troppo piccola! Uso limmagine originale e incrocio le dita\n');
        mask_grid = mask;
        img_grid = img;
        max_attempts_per_patch = max_attempts_per_patch*2;
        max_attempts = max_attempts_per_patch * num_patches;
        acceptability_threshold = 2*acceptability_threshold/3;
        celldim = [ floor(size(img_grid,1)/grid_rows), floor(size(img_grid,2)/grid_cols) ];
    else
        %se la griglia è troppo piccola, ritorno i campioni da tutta l'immagine
        patches_grid = random_patch_sample_fn( img, prows, pcols, num_patches*grid_rows*grid_cols, 1, 1 );
        return
    end
end

global_succ_count = 0;

for riga=1:grid_rows
    for colonna=1:grid_cols
        patches = cell(1,num_patches);
        
        succ_count = 0;
        
        mask = mask_grid((riga-1)*celldim(1) + 1 : riga*celldim(1),(colonna-1)*celldim(2) + 1 : colonna*celldim(2));
        img = img_grid((riga-1)*celldim(1) + 1 : riga*celldim(1),(colonna-1)*celldim(2) + 1 : colonna*celldim(2),:);
        
        
        %se non trovo nulla, prendo la patch più in alto a sinistra 
        bestpatch.r = 1;
        bestpatch.c = 1;
        tmp = mask(bestpatch.r:bestpatch.r + prows - 1, bestpatch.c:bestpatch.c + pcols -1);
        bestpatch.val = sum(tmp(:));

        for att=1:max_attempts
            r = randi(size(img,1)- prows + 1);
            c = randi(size(img,2)- pcols + 1);
            tmp = mask(r:r + prows - 1, c:c + pcols -1);
            tmp = sum(tmp(:));
            %se almeno acceptability_threshold percento di pixel sono dentro
            if tmp >= acceptability_threshold * prows * pcols
                %accetto la patch
                succ_count = succ_count + 1;
                patches{succ_count}.img = img(r:r + prows - 1, c:c + pcols -1, :);
                if succ_count >= num_patches
                    break
                end
            end

            %mi segno la patch migliore (in termini di quanto è dentro il vestito),
            %la uso più avanti in caso non trovi patch decenti
            if bestpatch.val < tmp
                bestpatch.val = tmp;
                bestpatch.r = r;
                bestpatch.c = c;
            end
        end

        if succ_count < num_patches
            if succ_count > 0
                %se ne ho almeno una riuscita, le rimanenti non sono altro che
                %copie di quelle campionate a caso con ripetizione
                remaining = num_patches - succ_count;
                patches(succ_count + 1:num_patches) = patches(randsample(succ_count, remaining, true));
            else
                for i=1:num_patches
                    patches{i}.img = img(bestpatch.r:bestpatch.r + prows - 1, bestpatch.c:bestpatch.c + pcols -1, :);
                end
            end

        end
        
        
        patches_grid(global_succ_count+1:global_succ_count+num_patches) = patches(:);
        global_succ_count = global_succ_count + num_patches;
    end
end




end


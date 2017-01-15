function [ patches ] = random_patch_sample_fn( img, prows, pcols, num_patches )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%Settings
max_attempts_per_patch = 4;
max_attempts = max_attempts_per_patch * num_patches;
acceptability_threshold = 0.9;


patches = cell(1,num_patches);

%faccio bounding box e restringo immagine e maschera lì
mask = maschera_binaria_fn(img);
rprops = regionprops(mask,'Image','BoundingBox','Area');
[~,index] = max([rprops.Area]);
mask = rprops(index).Image;
bbcoords = rprops(index).BoundingBox;
img = img(ceil(bbcoords(2)):ceil(bbcoords(2))+bbcoords(4)-1,ceil(bbcoords(1)):ceil(bbcoords(1))+bbcoords(3)-1,:);

succ_count = 0;
bestpatch.val = 0;
bestpatch.r = 0;
bestpatch.c = 0;

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


end


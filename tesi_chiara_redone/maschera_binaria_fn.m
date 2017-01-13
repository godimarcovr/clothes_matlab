
function mask=maschera_binaria_fn(Ir)
% Ir: Immagine da cui estrarre la maschera binaria
 %Ir = imresize(Ir, 0.5);

% Uncomment the following lines if segmentation is not good
Ir = rgb2gray(Ir); %se porto in grayscale i colori vanno tra zero e 1, quindi Ir(1,1)-4 deve diventare -0.04 almeno

bw = ones(size(Ir));%tutto bianco
bw(Ir(:) >= Ir(1,1)-4) = 0; %coloro di nero tutto ciò che e' sfondo
mask = bw;%maschera con bg nero e fg bianco
mask = imfill(bwmorph(mask, 'bridge'), 'holes'); %tappa buchi

CC = bwconncomp(mask, 4);%calcola componenti connesse
[~, M] = (max(cellfun(@length, CC.PixelIdxList)));%trova l'indice della piu grande componente connessa
mask = zeros(size(Ir,1), size(Ir,2));
mask(CC.PixelIdxList{M}) = 1;%colora di bianco la piu grande componente connessa

mask = ~bwareaopen(~mask, 4);

se = strel('disk', 3);
mask = imerode(mask, se);


% CC = bwconncomp(mask, 4);
% [~, M] = (max(cellfun(@length, CC.PixelIdxList)));
% mask = zeros(size(Ir,1), size(Ir,2));
% mask(CC.PixelIdxList{M}) = 1;

%figure
%subplot(1,2,1), imshow(mask, []);
% tmp = repmat(bsxfun(@times, im2double(Ir), mask), [1 1 3]);
% 
% tmpR = tmp(:,:,1);
% tmpR(~mask) = 255;
% tmp(:,:,1) = tmpR;

%subplot(1,2,2), imshow(tmp);

%keyboard;
end



















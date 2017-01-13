function shapefeat_vect = get_shape_features_fn( dataset_info,dim_img, img_resize_factor )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

fprintf('Inizio calcolo maschere binarie.\n')

dim_maschera = imresize(zeros(dim_img),img_resize_factor);
dim_maschera = size(dim_maschera(:),1);

shapefeat_vect = zeros(size(dataset_info,1),dim_maschera);

for i=1:size(dataset_info,1)
    if mod(i,100)==0
        fprintf('Immagine numero %i\n',i);
    end
    %leggo e ridimensiono l'immagine
    nome_immagine = dataset_info{i}.filename;
    img = imread(nome_immagine);
    img = imresize(img, dim_img);
    img = imresize(img, img_resize_factor);
    %e ne calcolo la maschera binaria, e la salvo
    maschera=maschera_binaria_fn(img);
    shapefeat_vect(i,:)=maschera(:)';
end

fprintf('Fine calcolo maschere binarie.\n')

end


function rpfeat_vect = get_region_props_fn( img_name,dim_img,microdim )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

img = imread(img_name);
img = imresize(img, dim_img);
maschera=maschera_binaria_fn(img);
%in teoria sono ordinati dalla più grande alla più piccola, quindi dovrebbe
%ignorare delle microregioni che compaiono a caso dovute a rumore
rprops = regionprops(maschera,'Eccentricity','EulerNumber','Area','ConvexArea','Image');

%(senza shapeprops le performance sono del 10%, con eccentricty e euler
%vado a 15%)

%aggiungere area/areaconvessa fa passare dal 15 al 20% in accuracy!
[~,index] = max([rprops.Area]);
arearatio = rprops(index).Area/rprops(index).ConvexArea;

% prendo la bounding box dell'immagine e faccio un resize a dimensioni
% molto piccole, in modo da avere info sulle regioni del vestito
% aggiungere micromask con 6x4 elementi fa passare l'accuracy da 20 al 40!
% con 9x6 da 40 a 47!  e con 30x20 64% (se qui tolgo colore-texture 62%)
% se faccio 60x40 scende al 63!

%micromask = bwmorph(imresize(rprops(1).Image,microdim),'remove');
micromask = imresize(rprops(index).Image,microdim);
%holes = ~close_holes_smallerthan_fn( micromask, numel(micromask)*0.02 );


% subplot(1,3,1);
% imagesc(img);
% subplot(1,3,2);
% imagesc(micromask);
% subplot(1,3,3);
% imagesc(holes);
% waitforbuttonpress

rpfeat_vect = [rprops(index).Eccentricity, rprops(index).EulerNumber, arearatio, micromask(:)'];

end


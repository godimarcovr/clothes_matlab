function topcolors = global_color_fn( img_name,dim_img, numcolors, colorspace )
%UNTITLED Summary of this function goes here
 %TODO: aggiungere anche info di quantità (es percentuale?)
 %TODO: aggiungere possibilità di altri spazi colore (es CIELAB)

img = imread(img_name);
img = imresize(img, dim_img);
mask=maschera_binaria_fn(img);
scale = 0.3;
img = imresize(img, scale);
mask = imresize(mask, scale);


rprops = regionprops(mask,'Image','BoundingBox','Area');
[~,index] = max([rprops.Area]);
mask = rprops(index).Image;
bbcoords = rprops(index).BoundingBox;
img = img(ceil(bbcoords(2)):ceil(bbcoords(2))+bbcoords(4)-1,ceil(bbcoords(1)):ceil(bbcoords(1))+bbcoords(3)-1,:);
pixR = img(:,:,1);
pixG = img(:,:,2);
pixB = img(:,:,3);
pixels = double([pixR(mask) pixG(mask) pixB(mask)])'./255;
topcolors = zeros(1,numcolors*3);
[~,nearest]=rgb2name(pixels);
[colorhist,~]=histcounts(nearest,[1:460,460]);
[~, topcolors] = sort(colorhist,'descend');
topcolors = topcolors(1:numcolors);
topcolors = name4602rgb_fn(topcolors);

if strcmp(colorspace,'cielab')
    topcolors = rgb2lab(topcolors);
end
topcolors = topcolors(:)';


end


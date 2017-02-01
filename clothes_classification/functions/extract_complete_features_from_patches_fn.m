function [ coppie_descrittori ] = extract_complete_features_from_patches_fn( patches, patch_rows, patch_cols,uniforme_ent_tresh,texthresh, num_colors, nocheck, colormode )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% settings
totpatches = size(patches,2);

if ~exist('nocheck','var')
    nocheck=0;
end

if strcmp(colormode,'460')
    color_dim = 1;
elseif strcmp(colormode,'rgb')
    color_dim = 3;
elseif strcmp(colormode,'cielab')
    color_dim = 3;
end

single_patch_dim = (color_dim*num_colors+28);

coppie_descrittori = zeros(totpatches,single_patch_dim);

%% start

fCLNM460hist = zeros(totpatches,460);
fCLNM460ent = zeros(1,totpatches);
fCLNM460max = zeros(1,totpatches);
for i=1:totpatches
    patch                  =   double(patches{i}.img);
    tmpvect                 =   reshape(patch,patch_rows*patch_cols,3)'./255;
    [~,nearest]             =   rgb2name(tmpvect);
    [N,~]                   =   histcounts(nearest,[1:460,460]);
    fCLNM460hist(i,:)     =   N;
    fCLNM460ent(i)        =   entropy(N);
    [~, inde]               =   max(N);
    fCLNM460max(i)        =   inde;
    [~, topcolors] = sort(N,'descend');
    topcolors = topcolors(1:num_colors);
    if strcmp(colormode,'460')
        topcolors = topcolors./460;
    elseif strcmp(colormode,'rgb')
        topcolors = name4602rgb_fn(topcolors);
        topcolors = topcolors(:)';
    elseif strcmp(colormode,'cielab')
        topcolors = name4602rgb_fn(topcolors);
        topcolors = rgb2lab(topcolors);
        topcolors = topcolors(:)';
    end
    
    %scopro se è almeno textured
    J = rangefilt(patch);
    J = sum(J(:));
    %se è textured, ne calcolo anche tamura e
    %graycooccurrences (rangefilt l'ho gia calcolata)
    %problema soglie, patch quasi del tutto bianche come intimo ecc non
    %rientrano dentro...
    if fCLNM460ent(i)<uniforme_ent_tresh || J>texthresh || nocheck
%         imshow(patches{i}.img)
%         waitforbuttonpress
        patch = patch./255;
        tamura_desc=Tamura3Sigs(patch);
        tmpimg = rgb2gray(patch);%rgb2gray(patches_sel{i}{j}.img);
        glcm = graycomatrix(tmpimg,'Offset',[0 1; -1 1;-1 -1;0 3; -3 3;-3 -3]);%,'NumLevels',16);
        stats = graycoprops(glcm);
        tmp = [stats.Contrast , stats.Correlation, stats.Energy, stats.Homogeneity];
        tmp(isnan(tmp))=0;
        
%         %ma viene sempre questo?
%         if ~all(tmp == [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1])
%             fprintf('diverso\n');
%         else
%             fprintf('=');
%         end
        
        coppie_descrittori(i,:) = [topcolors J tmp tamura_desc];
    end
end
% coppie_descrittori(all(coppie_descrittori==0,2),:)=[];

end


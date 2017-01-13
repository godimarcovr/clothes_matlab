function [ coppie_descrittori ] = extract_features_from_patch_fn_for_test( patches, patch_rows, patch_cols, patch_subsample,uniforme_ent_tresh,texthresh, descrittori_di_confronto, tipi_textures )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% settings
totpatches = size(patches,2);
coppie_descrittori = zeros(totpatches,2);

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
    if fCLNM460ent(i)<uniforme_ent_tresh
        coppie_descrittori(i,:) = [inde 0];
    else
        %scopro se è almeno textured
        J = rangefilt(patch);
        J = sum(J(:));
        %se è textured, ne calcolo anche tamura e
        %graycooccurrences (rangefilt l'ho gia calcolata)
        if J>texthresh
			patch = patch./255;
            tamura_desc=Tamura3Sigs(patch);
            tmpimg = rgb2gray(patch);%rgb2gray(patches_sel{i}{j}.img);
            glcm = graycomatrix(tmpimg,'Offset',[0 1; -1 1;-1 -1;0 3; -3 3;-3 -3]);%,'NumLevels',16);
            stats = graycoprops(glcm);
            tmp = [stats.Contrast , stats.Correlation, stats.Energy, stats.Homogeneity];
            tmp(isnan(tmp))=0;
            %costruisco il vettore di feature di texture
            feat_text=[J tmp tamura_desc];
            %ora che ho il descrittore, cerco il descrittore
            %piu vicino fra quelli del suo cluster di forma
            ind=knnsearch(descrittori_di_confronto,feat_text);
            texture=tipi_textures(ind); %restituisce il numero della texture dell elemento piu vicino
            coppie_descrittori(i,:) = [inde texture];
        end
    end
end
coppie_descrittori(all(coppie_descrittori==0,2),:)=[];

end


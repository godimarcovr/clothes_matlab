function [ featuresfinal, descrittori, clust_text ] = extract_features_from_patch_fn( patches, totpatches, patch_rows, patch_cols, patch_subsample,uniforme_ent_tresh,texthresh, indecouple )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%    Patches: un cell array che per ogni immagine del cluster ha un cell
%    array di patch
%    totpatches: totale delle patch perle immagini di questo cluster
%    indecouple: vettore di coppie (id_immagine,id_patch)

%% SETTINGS
numclusters = 10;

num_immagini_cl = size(patches,2);

%estraggo info colore per ogni patch
ind = 0;
%istogramma dei colori
fCLNM460hist = zeros(totpatches,460);
%entropia
fCLNM460ent = zeros(1,totpatches);
%colore più frequente
fCLNM460max = zeros(1,totpatches);
for i=1:size(patches,2)
    for j=1:size(patches{i},2)
        ind                     =   ind+1;
        tmpimg                  =   double(patches{i}{j}.img);
        tmpvect                 =   reshape(tmpimg,patch_rows*patch_cols,3)'./255;
        [~,nearest]             =   rgb2name(tmpvect);
        [N,~]                   =   histcounts(nearest,[1:460,460]);
        fCLNM460hist(ind,:)     =   N;
        fCLNM460ent(ind)        =   entropy(N);
        [~, inde]               =   max(N);
        fCLNM460max(ind)        =   inde;
    end
end
%fCLNM460hist_per_cluster{indcl}= fCLNM460hist;
%fCLNM460ent_per_cluster{indcl}=fCLNM460ent;
%fCLNM460max_per_cluster{indcl}=fCLNM460max;

%% individuazione delle patch uniformi
%preparo un array che mi darà gli indici delle patch che sono uniformi
ind_patch_uniformi = zeros(totpatches,1);
%per ciascuna patch
for i=1:totpatches
    %se l'entropia è sotto la soglia, me la segno
    if fCLNM460ent(i)<uniforme_ent_tresh
        ind_patch_uniformi(i) = i;
    end
end
%tolgo le patch non uniformi
ind_patch_uniformi=ind_patch_uniformi(ind_patch_uniformi~=0);
%per ogni patch uniforme, leggo l'istogramma dei colori
purefeatures = fCLNM460hist(ind_patch_uniformi,:);

%per ogni patch uniforme, calcolo il colore massimo
indmax=zeros(1,size(ind_patch_uniformi,1));
for i=1:size(ind_patch_uniformi,1);
    %non è la stessa cosa di fCLNM460max?
    %per ognipatch uniforme, trovo l'indice del valore massimo
    %nell'istogramma della patch
    [~,indmax(i)] = max(purefeatures(i,:));
end

%variabile di supporto per sapere fino a che punto sono arrivato col
%descrittore
occurrences=zeros(1,num_immagini_cl);
%occurrences=zeros(1,max(indecouple(ind_patch_uniformi,1))); non solo di
%quelle uniformi se poi lo uso anche per le textured!
%per ogni immagine del cluster, ho un descrittore per ogni patch
descrittori = cell(num_immagini_cl,patch_subsample);
%per ogni patch uniforme
for i=1:size(ind_patch_uniformi,1)
    indiceimmagine=indecouple(ind_patch_uniformi(i),1);
    occurrences(indiceimmagine)=occurrences(indiceimmagine)+1;
    %salvo nei descrittori dell'immagine nella prima posizione vuota
    %disponibile un descrittore [max, 0]
    descrittori{indiceimmagine,occurrences(indiceimmagine)}=[indmax(i),0];
end

%ci va anche il pezzo che starebbe qua?
%calcolo patches_vis_uniformi_per_cluster


%% identificazione delle patch textured
featuresRFILT = zeros(totpatches,1);
ind = 0;

%per ogni immagine del cluster
for i=1:num_immagini_cl
    %fprintf('\nCalcolo rangefilt immagine %i\n',i);
    % per ogni patch di ogni immagine calcolo il rangefilt
    for j=1:size(patches{i},2)
        ind = ind+1;
        tmpimg = patches{i}{j}.img;
        J = rangefilt(tmpimg);
        featuresRFILT(ind,1) = sum(J(:));
    end
end
%[~,index_tex] = sort(featuresRFILT);

%array con gli indici delle patch textured
ind_patch_textured = zeros(totpatches,1);
for i=1:totpatches
    %considero textured se il rangefiltering ha un certo valore
    if featuresRFILT(i)>texthresh
        ind_patch_textured(i) = i;
    end
end
ind_patch_textured=ind_patch_textured(ind_patch_textured~=0);

%per ciascuna di queste mi segno il colore dominante
colortext = ones(size(ind_patch_textured,1),1).*-1;
for i=1:length(ind_patch_textured)
    colortext(i)=fCLNM460max(ind_patch_textured(i));
    %colore_della_texture{indcl}{goodtex(i)}=colortext(i);
end

%% feature sulle patch textured

%su tutte le patch textured calcolo tamura, features della GLCM

featuresTAMU = zeros(size(ind_patch_textured,1),3);
ind = 0;
for i=ind_patch_textured(:)'
    %fprintf('\nTamura patch %i\n',i);
    ind = ind+1;
    tmpimg = patches{indecouple(i,1)}{indecouple(i,2)}.img;
    tmp = Tamura3Sigs(tmpimg);
    featuresTAMU(ind,:) = tmp;
end

featuresGLCM = zeros(size(ind_patch_textured,1),24);
ind = 0;
for i=ind_patch_textured(:)'
    %fprintf('\nComatrix immagine %i\n',i);
    ind = ind+1;
    tmpimg = rgb2gray(patches{indecouple(i,1)}{indecouple(i,2)}.img);
    glcm = graycomatrix(tmpimg,'Offset',[0 1; -1 1;-1 -1;0 3; -3 3;-3 -3]);%,'NumLevels',16);
    stats = graycoprops(glcm);
    tmp = [stats.Contrast , stats.Correlation, stats.Energy, stats.Homogeneity];
    featuresGLCM(ind,:) = tmp;
end
featuresGLCM(isnan(featuresGLCM))=0;


featuresRFILT = featuresRFILT(ind_patch_textured);

%raggruppo tutte le features in un unico array
featuresfinal  = zeros(size(ind_patch_textured,1),28);
ind = 0;
for i=ind_patch_textured(:)'
    %fprintf('%i\n',i);
    ind = ind+1;
    featuresfinal(ind,:) = [featuresRFILT(ind),featuresGLCM(ind,:),featuresTAMU(ind,:)];
end

%normalizzo rispetto a media e scarto quadratico medio
featuresnfinal = (featuresfinal - repmat(mean(featuresfinal),[size(featuresfinal,1),1]))./...
    repmat(std(featuresfinal),[size(featuresfinal,1),1]);

%usare evalclusters se si cambia il dataset!!
if size(featuresnfinal,1) < numclusters
    numclusters = size(featuresnfinal,1);
end

%clusterizzo i valori delle features delle patch texturizzate
%come posso sapere quanti cluster fare?
if numclusters ~= 0
    [clusters,~]            =   kmeans(featuresnfinal, numclusters);
else
    clusters = [];
end
%tipi_di_texture{indcl}=clusters;
%features_final{indcl}=featuresnfinal;
%save tipi_di_texture_mat.mat tipi_di_texture features_final

%qua c'era un ciclo per visualizzare le texture
%e uno per i colori

%occurrences=zeros(1,max(indecouple(ind_patch_uniformi,1)));
%Errore qua? perché lo inizializza di nuovo, così sovrascrive i
%descrittori!
%descrittori = cell(num_immagini_cl,patch_subsample);
%per ogni patch texturizzata
for i=1:size(ind_patch_textured,1)
    indiceimmagine=indecouple(ind_patch_textured(i),1);
    occurrences(indiceimmagine)=occurrences(indiceimmagine)+1;
    %salvo nei descrittori dell'immagine nella prima posizione vuota
    %disponibile un descrittore [max, 0]
    descrittori{indiceimmagine,occurrences(indiceimmagine)}=[colortext(i) clusters(i)];
end

clust_text = clusters;

end


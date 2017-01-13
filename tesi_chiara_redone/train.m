%% SETTINGS
clear all
close all

dataset_name = 'small_FT_train';
img_resize_factor = 0.5;
%per ora assumo tutte alla stessa dimensione, come in teoria le API
%dovrebbero garantire
dim_img = [1100 762];

% kmeans settings
% va valutato sul dataset
% per ora metto il numero di categorie lette dal dataset
cd datasets
cd(dataset_name)
dataset_info = read_dataset_csv(strcat(dataset_name,'.csv'));
dataset_info=dataset_info(:,7);
num_shape_clusters = size(unique(dataset_info),1);
cd ..
cd ..

% texture and color settings
patch_rows = 64;
patch_cols = 64;
patch_stride = 30;
patch_subsample = 25;

% color settings
uniforme_ent_tresh   =   0.08;

% texture settings
texthresh   =   300000;

%% Lettura dati di training per clustering di forma
cd datasets
cd(dataset_name)
dataset_info = read_dataset_csv(strcat(dataset_name,'.csv'));
% attenzione, metterci gli indici di colonne dell'id e del nome della
% categoria di interesse
dataset_info=dataset_info(:,[1,7]);
cd ..
cd ..

%% clustering di forma
%in futuro, usare una classificazione in macrocategorie più furba, ad
%esempio una CNN o una SVM sulle immagini grayscale

cd datasets
cd(dataset_name)

[clusters, maschere] = clustering_forma_fn(dataset_info,img_resize_factor,dim_img,num_shape_clusters);

cd ..
cd ..
clear dataset_info

%load(strcat('shape_kmeans_',dataset_name))
save(strcat('shape_kmeans_',dataset_name),'clusters','maschere');

%% feature colore/texture e cluster su di esse

cd datasets
cd(dataset_name)

% preparo i nomi di tutte le immagini
dataset_info = read_dataset_csv(strcat(dataset_name,'.csv'));
dataset_info = dataset_info(:,1);

%dim_maschera_big = zeros(dim_img);
%dim_maschera_big = size(dim_maschera_big(:),1);

descrittori_per_cl = cell(1,num_shape_clusters);

%calcolo la numerosità del cluster più numeroso
[~,maxfreq]=mode(clusters);

%mi costruisco una struttura dati che contiene per ogni cluster di forma,
%i nomi delle immagini appartenenti ad esso
nomi_immagini_per_cluster = cell(num_shape_clusters,maxfreq);
for cl=1:num_shape_clusters
    indici = find(clusters==cl);
    indici = indici(:)';
    count = 0;
    for i=indici
        count = count + 1;
        nomi_immagini_per_cluster{cl,count} = dataset_info{i,1};
    end
end

featuresfinal_shape = cell(num_shape_clusters,1);
tipi_textures = cell(num_shape_clusters,1);

% per ogni cluster di forma
parfor cl=1:num_shape_clusters
    fprintf('Inizio cluster %i \n',cl);
    %prendo tutti gli indici delle immagini di questo cluster
    indici = find(clusters==cl);
    indici = indici(:)';
    %     num_immagini_cl = size(indici,2);
    
    %preparo una struttura dati per le patch delle immagini
    patches = cell(size(indici));
    %maschere_big = zeros(size(dataset_info,1),dim_maschera_big);
    
    %recupero le patch per ogni immagine di questo cluster
    count = 0;
    totpatches = 0;
    %matrice che in ogni riga ha una coppia (immagine,patch) numerati
    indecouple=zeros(size(indici,2)*patch_subsample,2);
    
    %per ogni immagine del cluster
    for i=indici
        count = count + 1;
        %leggo immagine e calcolo maschera
        img = imread(strcat(dataset_info{i,1},'.jpg'));
        maschera_big = maschera_binaria_fn(img);
        %estraggo array di patch valide (dentro il vestito)
        patches_tmp = ext_patches_mask(img, maschera_big, patch_rows, patch_cols, patch_stride);
        %ne salvo un sottoinsieme casuale grande al massimo patch_subsample
        patches{count}=patches_tmp(randsample(size(patches_tmp,2),min(patch_subsample,size(patches_tmp,2))));
        oldtotpatches = totpatches;
        totpatches = totpatches + size(patches{count},2);
        %salvo le coppie (numimmagine,numpatch)
        indecouple(oldtotpatches+1:totpatches,1:2) = [ones(size(patches{count},2),1)*count (1:size(patches{count},2))'];
    end
    
    %rimuovo le righe nulle
    indecouple=reshape(indecouple(indecouple~=0),size(indecouple(indecouple~=0),1)/2,2);
    %estraggo le features dalle patch
    [featuresfinal, descrittori,clust_text] = extract_features_from_patch_fn(patches, totpatches,patch_rows,patch_cols,patch_subsample,uniforme_ent_tresh,texthresh,indecouple);
    descrittori_per_cl{cl} = descrittori;
    featuresfinal_shape{cl,1} = featuresfinal;
    tipi_textures{cl} = clust_text;
    fprintf('Fine cluster %i \n',cl);
end


% calcolo per ogni vestito un indice univoco per lo stile che esso ha
[ clusters_ind, maxcl, labels ] = most_frequent_descriptor_fn( clusters, num_shape_clusters, descrittori_per_cl );


cd ..
cd ..


%% compilo matrice cooccorrenze fra cluster

% usando la nuova suddivisione in sottostili, costruisco una matrice di
% cooccorrenze

cd datasets
cd(dataset_name)
dataset_info = read_dataset_csv(strcat(dataset_name,'.csv'));
% attenzione, metterci gli indici di colonne dell'id e del nome della
% categoria di interesse
dataset_info=dataset_info(:,[1,6]);
cd ..
cd ..

cooccorrenze_mat = cooccorrenze( dataset_info, clusters_ind, nomi_immagini_per_cluster, maxcl );


%% matrice di confusione tra nostra classificazione e quella di zalando

cd datasets
cd(dataset_name)
dataset_info = read_dataset_csv(strcat(dataset_name,'.csv'));
% attenzione, metterci gli indici di colonne dell'id e del nome della
% categoria di interesse
dataset_info=dataset_info(:,7);
categories_list = unique(dataset_info);
dataset_info = read_dataset_csv(strcat(dataset_name,'.csv'));
dataset_info=dataset_info(:,[1,7]);
cd ..
cd ..

categorie = confusion_trainingset_fn( nomi_immagini_per_cluster, clusters_ind, dataset_info, categories_list, maxcl );


%save train_vars.mat <quello che serve>
save(strcat(dataset_name,'_train_vars.mat'));







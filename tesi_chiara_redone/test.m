%% initialization
clear all
close all

test_dataset_name = 'small_FT_test';
train_dataset_name = 'small_FT_train';
img_resize_factor = 0.5;
%per ora assumo tutte alla stessa dimensione, come in teoria le API
%dovrebbero garantire
dim_img = [1100 762];

% kmeans settings
% va valutato sul dataset
%evalclusters ha detto 3...
%num_shape_clusters = 14;

% texture and color settings
% patch_rows = 64;
% patch_cols = 64;
% patch_stride = 30;
% patch_subsample = 25;

% % color settings
% uniforme_ent_tresh   =   0.08;
% 
% % texture settings
% texthresh   =   300000;
% categorie di vestiti (si può calcolare?)
numcat=14;

load(strcat(train_dataset_name,'_train_vars.mat'));

%% Lettura dati di training per clustering di forma
cd datasets
cd(test_dataset_name)
test_dataset_info = read_dataset_csv(strcat(test_dataset_name,'.csv'));
% attenzione, metterci gli indici di colonne dell'id e del nome della
% categoria di interesse
test_dataset_info=test_dataset_info(:,[1]);
cd ..
cd ..


%% DATE DELLE IMMAGINI DI TEST, PER OGNI IMMAGINE PROPONE IL CLUSTER DEL TRAINING SET CHE MEGLIO SI ABBINA

%le maschere dal training sono nella variable 'maschere' che dovrebbe
%tirare giù con il load. I cluster assegnati sono nella variabile 'clusters'

%faccio le maschere per tutti i vestiti nel testing set
dim_maschera = imresize(zeros(dim_img),img_resize_factor);
dim_maschera = size(dim_maschera(:),1);

maschere_test = zeros(size(test_dataset_info,1),dim_maschera);

cd datasets
cd(test_dataset_name)

for i=1:size(test_dataset_info,1)
    nome_immagine = strcat(test_dataset_info{i,1},'.jpg');
    img = imread(nome_immagine);
    img = imresize(img, img_resize_factor);
    maschera=maschera_binaria_fn(img);
    maschere_test(i,:)=maschera(:)';
end



%per ognuna delle immagini di test, faccio knn search

forma = zeros(1,size(maschere_test,1));

for i=1:size(maschere_test,1)
    idx=knnsearch(maschere,maschere_test(i,:));
    forma(i)=clusters(idx);
end

%trovo le patch per ogni immagine di test

totpatches_test = 0;
count = 0;
%salvo in test_patches{i} un cell array con tutte le patch dell'i-esima
test_patches = cell(size(test_dataset_info,1),1);
%coppie (id vestito, id patch)
indecouple_test=zeros(size(test_dataset_info,1)*patch_subsample,2);

for i=1:size(test_dataset_info,1)
    fprintf('Estrazione patch da immagine %i di %i \n',i,size(test_dataset_info,1));
    %leggo immagine e calcolo maschera
    img = imread(strcat(test_dataset_info{i,1},'.jpg'));
    maschera_big = maschera_binaria_fn(img);
    %estraggo array di patch
    patches_tmp = ext_patches_mask(img, maschera_big, patch_rows, patch_cols, patch_stride);
    %ne salvo un sottoinsieme casuale
    test_patches{i}=patches_tmp(randsample(size(patches_tmp,2),min(patch_subsample,size(patches_tmp,2))));
    oldtotpatches_test = totpatches_test;
    totpatches_test = totpatches_test + size(test_patches{i},2);
    %segno le appartenenze
    indecouple_test(oldtotpatches_test+1:totpatches_test,1:2) = [ones(size(test_patches{i},2),1)*i (1:size(test_patches{i},2))'];
end
%rimuovo le righe nulle
indecouple_test=reshape(indecouple_test(indecouple_test~=0),size(indecouple_test,1),2);

%dove per ogni immagine, ho un descrittore per ogni patch
coppie_descrittori = cell(size(test_dataset_info,1),1);
% per ciascuna immagine
for i=1:size(test_dataset_info,1)
    fprintf('Calcolo feature patch da immagine %i di %i \n',i,size(test_dataset_info,1));
    %calcolo le feature delle patch texturate e i descrittori per pure e
    %texturate
    %patch_img = cell(1,size(test_patches{i},2));
    patch_img= test_patches{i};
    patch_img = patch_img(~cellfun('isempty',patch_img));
    
    %recupero i descrittori dello stesso cluster di forma
    descrittori_di_confronto = featuresfinal_shape(forma(i));
    descrittori_di_confronto = descrittori_di_confronto{1};
    texture_types = tipi_textures{forma(i)};
    
    desc_couples = extract_features_from_patch_fn_for_test( patch_img, patch_rows, patch_cols, patch_subsample,uniforme_ent_tresh,texthresh, descrittori_di_confronto, texture_types );
    
    coppie_descrittori{i} = desc_couples;
    
end

cluster_finale = look_for_nearest_fn( coppie_descrittori, test_dataset_info,labels,nomi_immagini_per_cluster, train_dataset_name, forma, clusters_ind );
%gli abbinamenti vanno aggiunti!!
%save tmp_test test_dataset_info train_dataset_name cluster_finale maxcl cooccorrenze_mat categorie clusters_ind nomi_immagini_per_cluster numcat categories_list test_dataset_name -v7.3
% immagini abbinamenti temporaneamente rimossi a causa di memory leak
[cluster_abbinato,abbinamenti] = cerca_abbinamenti_fn( test_dataset_info, train_dataset_name, cluster_finale,maxcl,cooccorrenze_mat, categorie, clusters_ind, nomi_immagini_per_cluster );


%% calcolo matrice di confusione

test_dataset_info = read_dataset_csv(strcat(test_dataset_name,'.csv'));
test_dataset_info=test_dataset_info(:,[7,1]);

confusion_testingset_fn( test_dataset_info,numcat,cluster_finale,categories_list,categorie );

%pezzo sulla coerenza?

%mettere in una funzione
create_usertest_fn(test_dataset_info, train_dataset_name, test_dataset_name,clusters_ind,cluster_abbinato,cluster_finale,abbinamenti,nomi_immagini_per_cluster);

cd ..
cd ..

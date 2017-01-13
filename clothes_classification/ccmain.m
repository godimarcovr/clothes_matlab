clear all

test_dataset_name = 'balanced_specific_test';
train_dataset_name = 'balanced_specific_train';

%più grande è più preciso è il risultato, ma aumenta la memoria necessaria
img_resize_factor = 0.5;
%per ora assumo tutte alla stessa dimensione, come in teoria le API
%dovrebbero garantire
dim_img = [1100 762];

% color settings
uniforme_ent_tresh   =   0.08;

% texture settings
texthresh   =   300000;

% texture and color settings
patch_rows = 64;
patch_cols = 64;
patch_stride = 30;
patch_subsample = 25;

%features
% featlist = {{'shapeprops'},{'color_text'}};
shapeprops_microdim = [30 20];
global_color_num_colors = 3;
global_color_num_colorspace = 'rgb';
color_text_num_colors = 3;
color_text_num_patches = 4;
color_text_num_colorspace = 'rgb';

featlist = {{'shapeprops', shapeprops_microdim}...
    ,{'global_color', global_color_num_colors, global_color_num_colorspace}...
    ,{'color_text', color_text_num_patches, color_text_num_colors, color_text_num_colorspace}};

%macrocategorie
macro_categories_list = {'Borse';'Top';'Cappelli';'Cinture';'Foulard & Sciarpe';'Gonne';'Intimo';'Pantaloni';'Vestiti'};
inside_macro = {{},{'Camicie','Cappotti','Giacche','Maglieria & Felpe','T-shirt & Top'},{},{},{},{},{},{'Jeans','Pantaloni'},{}};

% classificatore
nearneighnum = 1;

%% leggo dati di training

fprintf('Leggo dataset %s ....\n',train_dataset_name);

cd datasets
cd(train_dataset_name)
train_dataset_info = read_dataset_csv(strcat(train_dataset_name,'.csv'));
% attenzione, metterci gli indici di colonne dell'id e del nome della
% categoria di interesse
train_dataset_info=train_dataset_info(:,[1,7]);

cd ..
cd ..

%lista categorie e id associato
categories_list = unique(train_dataset_info(:,2));


%cell array di struct che contengono le info come nome file, categoria,
%numero di categoria classificata ecc
trainset_info = cell(size(train_dataset_info,1),1);

for i=1:size(train_dataset_info,1)
    trainset_info{i}.filename = strcat(train_dataset_info{i,1},'.jpg');
    trainset_info{i}.category = train_dataset_info{i,2};
    trainset_info{i}.macrocategory = trainset_info{i}.category;
    for j=1:size(inside_macro,2)
        mres=strfind(inside_macro{j},trainset_info{i}.category);
        if size(mres,1)>0 && ~all(cellfun('isempty',mres))
            trainset_info{i}.macrocategory = macro_categories_list{j};
            break
        end
    end
end

fprintf('... letto!\n');

%% calcolo features train

cd datasets
cd(train_dataset_name)

fprintf('Inizio calcolo features.\n')
% 
% for i=1:size(train_dataset_info,1)
%     img=imread(trainset_info{i}.filename);
%     maschera=maschera_binaria_fn(img);
%     rprops = regionprops(maschera,'Image');
%     bw = bwmorph(bwmorph(imresize(rprops(1).Image,[30 20]),'thin',3),'skel',Inf);
%     %bw=bwmorph(imresize(rprops(1).Image,[150 100]),'remove');
%     subplot(1,3,1);
%     imshow(img);
%     subplot(1,3,2);
%     imshow(imresize(rprops(1).Image,[30 20]));
%     subplot(1,3,3);
%     imshow(bw);
%     waitforbuttonpress
% end

[train_feat_vectors,featmins,featmaxs] = get_features_fn(trainset_info,featlist,dim_img, img_resize_factor,uniforme_ent_tresh,texthresh,patch_rows, patch_cols, patch_stride,0);

fprintf('Fine calcolo features.\n')

cd ..
cd ..


%% training
kappa = size(categories_list,1);

fprintf('Inizio clustering kmeans.\n')

train_clusters = kmeans(train_feat_vectors,kappa);

fprintf('Fine clustering kmeans.\n')

for i=1:size(train_dataset_info,1)
    trainset_info{i}.cluster = train_clusters(i);
end

%% definisco associazioni cluster/categoria
%matrice che per ogni riga (categoria) mi dice come è stata distribuita nei
%cluster
associations = zeros(kappa,kappa);
for i=1:size(train_dataset_info,1)
    %trova l'indice della cella non vuota nell'array dove ho vuoto se non è
    %uguale alla categoria
    catind = find(not(cellfun('isempty', strfind(categories_list,trainset_info{i}.category))));
    associations(catind,trainset_info{i}.cluster) = associations(catind,trainset_info{i}.cluster) + 1;
    trainset_info{i}.category_num = uint8(round(catind-1));
end
figure; imagesc(associations); colorbar;
set(gca, 'YTick',1:1:kappa);
set(gca,'YTickLabelMode','manual');
set(gca, 'YTickLabel',categories_list);
set(gca, 'XTick',1:1:kappa);

%% leggo dati di test

fprintf('Leggo dataset %s ....\n',test_dataset_name);

cd datasets
cd(test_dataset_name)
test_dataset_info = read_dataset_csv(strcat(test_dataset_name,'.csv'));
% attenzione, metterci gli indici di colonne dell'id e del nome della
% categoria di interesse
test_dataset_info=test_dataset_info(:,[1,7]);

cd ..
cd ..

%cell array di struct che contengono le info come nome file, categoria,
%numero di categoria classificata ecc
testset_info = cell(size(test_dataset_info,1),1);

for i=1:size(test_dataset_info,1)
    testset_info{i}.filename = strcat(test_dataset_info{i,1},'.jpg');
    testset_info{i}.category = test_dataset_info{i,2};
    testset_info{i}.macrocategory = testset_info{i}.category;
    for j=1:size(inside_macro,2)
        mres=strfind(inside_macro{j},testset_info{i}.category);
        if size(mres,1)>0 && ~all(cellfun('isempty',mres))
            testset_info{i}.macrocategory = macro_categories_list{j};
            break
        end
    end
end

fprintf('... letto!\n');

%% calcolo features test

cd datasets
cd(test_dataset_name)

fprintf('Inizio calcolo features di test.\n')

[test_feat_vectors,~,~] =  get_features_fn(testset_info,featlist,dim_img, img_resize_factor,uniforme_ent_tresh,texthresh,patch_rows, patch_cols, patch_stride,[featmins;featmaxs]);


fprintf('Fine calcolo features di test.\n')

cd ..
cd ..

%% classificazione

fprintf('Inizio classificazione.\n')

for i=1:size(test_feat_vectors,1)
    if mod(i,100)==0
        fprintf('Immagine numero %i\n',i);
    end
    testset_info{i}.nearest_train_index = knnsearch(train_feat_vectors,test_feat_vectors(i,:),'K',nearneighnum);
end

fprintf('Fine classificazione.\n')

%% confusion

fprintf('Inizio calcolo matrice di confusione.\n')

confusion = zeros(kappa,kappa);

for i=1:size(test_dataset_info,1)
    %confronto le categorie fra questo e il punto più vicino
    testcatind = find(not(cellfun('isempty', strfind(categories_list,testset_info{i}.category))));
    testset_info{i}.category_num = uint8(round(testcatind-1));
    nearcats = zeros(1,nearneighnum);
    for j=1:nearneighnum
        nearest_train = trainset_info{testset_info{i}.nearest_train_index(j)};
        nearcats(j) = find(not(cellfun('isempty', strfind(categories_list,nearest_train.category))));
    end
    traincatind = mode(nearcats);
    confusion(testcatind,traincatind) = confusion(testcatind,traincatind) + 1;
end

fprintf('Inizio calcolo matrice di confusione.\n')

figure; imagesc(confusion); colorbar;
set(gca, 'YTick',1:1:kappa);
set(gca,'YTickLabelMode','manual');
set(gca, 'YTickLabel',categories_list);
set(gca, 'XTick',1:1:kappa);
set(gca,'XTickLabelMode','manual');
set(gca, 'XTickLabel',categories_list);

accuracy = sum(diag(confusion)) / sum(sum(confusion));

fprintf('Accuracy: %f .\n',accuracy);


% %% Neural Network Data
% 
% %testing set
% test_to_train_perc = 0.75;
% test_to_train_num = ceil(test_to_train_perc*size(test_feat_vectors,1));
% test_to_test_num = size(test_feat_vectors,1) - test_to_train_num;
% 
% test_to_train_vectors = test_feat_vectors(1:test_to_train_num,:);
% test_to_test_vectors = test_feat_vectors(test_to_train_num+1:end,:);
% 
% test_categories = zeros(size(testset_info,1),1);
% for i=1:size(testset_info,1)
%     test_categories(i,1) = testset_info{i}.category_num;
% end
% test_to_train_categories = test_categories(1:test_to_train_num,:);
% test_to_test_categories = test_categories(test_to_train_num+1:end,:);
% 
% cd datasets
% cd(test_dataset_name)
% 
% [test_to_test_vectors, test_to_test_categories] = data_augment_fn( test_to_test_vectors, test_to_test_categories, featlist );
% csvwrite(strcat(test_dataset_name,'__features.csv'),test_to_test_vectors);
% csvwrite(strcat(test_dataset_name,'__categories.csv'),test_to_test_categories);
% 
% cd ..
% cd ..
% 
% %training set
% 
% cd datasets
% cd(train_dataset_name)
% 
% train_categories = zeros(size(trainset_info,1),1);
% for i=1:size(trainset_info,1)
%     train_categories(i,1) = trainset_info{i}.category_num;
% end
% 
% [test_to_train_vectors, test_to_train_categories] = data_augment_fn( test_to_train_vectors, test_to_train_categories, featlist );
% [train_feat_vectors2, train_categories] = data_augment_fn( train_feat_vectors, train_categories, featlist );
% 
% csvwrite(strcat(train_dataset_name,'__features.csv'),[train_feat_vectors2; test_to_train_vectors]);
% csvwrite(strcat(train_dataset_name,'__categories.csv'),[train_categories; test_to_train_categories]);
% 
% cd ..
% cd ..
% 


%% MACRO
%% macrotraining
% macrokappa = size(macro_categories_list,1);
% 
% fprintf('Inizio clustering kmeans.\n')
% 
% train_clusters = kmeans(train_feat_vectors,macrokappa);
% 
% fprintf('Fine clustering kmeans.\n')
% 
% for i=1:size(train_dataset_info,1)
%     trainset_info{i}.macrocluster = train_clusters(i);
% end
% 
% %% definisco associazioni cluster/macrocategoria
% %matrice che per ogni riga (categoria) mi dice come è stata distribuita nei
% %cluster
% macroassociations = zeros(macrokappa,macrokappa);
% for i=1:size(train_dataset_info,1)
%     %trova l'indice della cella non vuota nell'array dove ho vuoto se non è
%     %uguale alla categoria
%     catind = find(not(cellfun('isempty', strfind(macro_categories_list,trainset_info{i}.macrocategory))));
%     macroassociations(catind,trainset_info{i}.macrocluster) = macroassociations(catind,trainset_info{i}.macrocluster) + 1;
% end
% figure; imagesc(macroassociations); colorbar;
% set(gca, 'YTick',1:1:macrokappa);
% set(gca,'YTickLabelMode','manual');
% set(gca, 'YTickLabel',macro_categories_list);
% set(gca, 'XTick',1:1:macrokappa);
% 
% %% macroconfusion
% 
% fprintf('Inizio calcolo matrice di confusione.\n')
% 
% macroconfusion = zeros(macrokappa,macrokappa);
% 
% for i=1:size(test_dataset_info,1)
%     %confronto le categorie fra questo e il punto più vicino
%     testcatind = find(not(cellfun('isempty', strfind(macro_categories_list,testset_info{i}.macrocategory))));
%     nearest_train = trainset_info{testset_info{i}.nearest_train_index};
%     traincatind = find(not(cellfun('isempty', strfind(macro_categories_list,nearest_train.macrocategory))));
%     macroconfusion(testcatind,traincatind) = macroconfusion(testcatind,traincatind) + 1;
% end
% 
% fprintf('Inizio calcolo matrice di confusione.\n')
% 
% figure; imagesc(macroconfusion); colorbar;
% set(gca, 'YTick',1:1:kappa);
% set(gca,'YTickLabelMode','manual');
% set(gca, 'YTickLabel',macro_categories_list);
% set(gca, 'XTick',1:1:kappa);
% set(gca,'XTickLabelMode','manual');
% set(gca, 'XTickLabel',macro_categories_list);
% 
% accuracy = sum(diag(macroconfusion)) / sum(sum(macroconfusion));
% 
% fprintf('MacroAccuracy: %f .\n',accuracy);

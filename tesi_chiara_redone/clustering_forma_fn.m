function [clusters, maschere] = clustering_forma_fn(dataset_info,img_resize_factor,dim_img,num_shape_clusters )
%CLUSTERING_FORMA FN effettua il kmeans con i parametri specificati e salva
%i cluster in immagini
%
%dataset_info: deve avere al primo posto la colonna con tutti i nomi usati
%per le immagini
%img_resize_factor:valore tra 0.0 e 1.0 che indica di quanto restringere le
%immagini (velocizza calcolo ma riduce accuratezza)
%dim_img:riga di due valori che indicano righe e colonne massime delle
%immagini in input
%num_shape_clusters: quanti cluster di forma voglio creare (valutarli caso
%per caso con evalclusters)

%calcolo dimensione immagine col resize creando un immagine finta delle
%dimensioni dell'immagine
dim_maschera = imresize(zeros(dim_img),img_resize_factor);
dim_maschera = size(dim_maschera(:),1);

maschere = zeros(size(dataset_info,1),dim_maschera);

%per tutte le immagini
parfor i=1:size(dataset_info,1)
    %leggo e ridimensiono l'immagine
    nome_immagine = strcat(dataset_info{i,1},'.jpg');
    img = imread(nome_immagine);
    img = imresize(img, img_resize_factor);
    %e ne calcolo la maschera binaria, e la salvo
    maschera=maschera_binaria_fn(img);
    maschere(i,:)=maschera(:)';
end

%faccio kmeans
fprintf('\nInizio clustering\n');
%eva = evalclusters(maschere,'kmeans','CalinskiHarabasz','KList',[1:2:15])

%options = statset('UseParallel',true);
%clusters=kmeans(maschere, num_shape_clusters,'Options',options);
%parallelizzando va più lento??
%perché è fatto in maniera non supervisionata?
clusters=kmeans(maschere, num_shape_clusters);
fprintf('\nFine clustering\n');


if ~exist('shape_clusters', 'dir')
    mkdir('shape_clusters');
end

% per ciascun cluster di forma
for cl=1:num_shape_clusters
    indcl=1;
    % mostro tutti i suoi membri
    f=figure;
    set(f, 'Visible', 'off');
    indexes=find(clusters(:,1)==cl);
    dim_cluster = size(indexes,1);
    for ind=indexes(:)'
        subplot(ceil(sqrt(dim_cluster)),ceil(sqrt(dim_cluster)),indcl);
        nome_immagine = strcat(dataset_info{ind,1},'.jpg');
        img = imread(nome_immagine);
        imshow(img);
        indcl=indcl+1;
    end
    cd shape_clusters
    nomecluster=strcat('cluster_',num2str(cl), '.jpg');
    saveas(f,nomecluster);
    cd .. %esci da clusters_forma e torna in allimg
end


end


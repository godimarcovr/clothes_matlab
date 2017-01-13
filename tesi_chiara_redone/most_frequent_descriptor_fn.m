function [ clusters_ind, maxcl,labels ] = most_frequent_descriptor_fn( clusters, num_shape_clusters, descrittori_per_cl )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%ad ogni immagine assegno l etichetta del descrittore piu frequente
% [~,maxfreq]=mode(clusters);
%da testare se funzionano
%labels = zeros(num_shape_clusters,maxfreq,2);
%tipo = zeros(num_shape_clusters,maxfreq);
labels = [];
tipo = [];
%per ogni cluster di forma
for indcl=1:num_shape_clusters
    %recupero i descrittori relativi
    descrittori=descrittori_per_cl{indcl};% e' una matrice di celle.
    %Ogni riga e' una immagine, ogni colonna l'id di una patch
    for img_i=1:size(descrittori,1)%per ogni immagine
        
        tmp=descrittori(img_i,:);%riga di celle (descrittori immagine)
        %tx=[];
        %voglio metterlo in una matrice Px2
        tx = zeros(size(tmp,2),2);
        count = 0;
        for k=1:size(tmp,2)
            if(size(tmp{k},2)==2) %se non e' una casella vuota (potrebbe esserlo se e' una patch non classificata o se e' una img con meno patch interne)
                %tx = [tx;tmp{k}];
                count = count + 1;
                tx(count,:) = tmp{k};
            end
        end
        %tolgo gli zeri finali (non serve?)
        tx = tx(1:count,:);
        if(isempty(tx))
            tx=[0 0]; %se l immagine e' totalmente costituita da patch inclassificabili
        end
        %recuepero l'etichetta più frequente nell'immagine
        [u,~,c] = unique(tx,'rows');
        [~,itx]=max(accumarray(c,1));
        etichetta_tx=u(itx,:);
        %la salvo in labels
        labels(indcl,img_i,:)=etichetta_tx;
        if(etichetta_tx(2)==0)
            tipo(indcl, img_i)=1;
        else
            tipo(indcl, img_i)=0;
        end
    end
    
end

clusters_ind=[];
%per ogni cluster di forma
for i=1:num_shape_clusters
    %prendo tutte le etichette di questo cluster
    etichette_long=labels(i,:,:); %prende tutte le coppie del cluster di forma iesimo
    %trova etichette non nulle
    
    %etichette_cluster=etichette_long(1,1:find(~and(etichette_long(:,:,1)==0 , etichette_long(:,:,2)==0 ) , 1, 'last' ),:);
    etichette_cluster=etichette_long;
    etichette_cl=reshape(etichette_cluster,[size(etichette_cluster,2),size(etichette_cluster,3),1]);
    %assegno un numero ad ogni etichetta
    [~,~,ic]=unique(etichette_cl,'rows');
    %per ogni vestito
    for k=1:size(etichette_cl,1)
        %mi segno l'indice di quello stile corrispondente
        clusters_ind(i,k)=ic(k);
        %se non ho descrittori, segno -1
        if(sum(etichette_cl(k,:))==0)
            clusters_ind(i,k)=-1;
        end
    end
end
%prendo l'indice massimo del primo cluster
tmp=clusters_ind(1,:);
maxcl=max((tmp));
%assegno un indice univoco a ciascun sottostile
%(mi segno dove ero arrivato il giro prima e incremento quelli diversi da
% -1)
for i=2:num_shape_clusters
    tmp=clusters_ind(i,:);
    numel=size((find( ~ tmp(:)==0)),1);
    indici_da_incrementare=(find(tmp(1:numel)~=-1));
    rep=repmat(maxcl,1,size(indici_da_incrementare,2));
    clusters_ind(i,indici_da_incrementare)=(clusters_ind(i,indici_da_incrementare))+rep;
    tmp2=clusters_ind(i,1:numel);
    maxcl=max(tmp2);
end

end


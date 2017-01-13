function categorie = confusion_trainingset_fn( nomi_immagini_per_cluster, clusters_ind, dataset_info, categories_list, maxcl )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
confusion=zeros(maxcl, 2);
categorie=zeros(maxcl,1);
%per ogni cluster
for indcl=1:size(nomi_immagini_per_cluster,1)
    indcl
    %tutti i nomi delle immagini del cluster di forma indcl-esimo
    %nomi_immagini=nomi_immagini_per_cluster{indcl,:};
    
    %per ogni sottostile del cluster
    for i=1:max(clusters_ind(indcl,:)) %per ogni cluster fra quelli di forma indcl
        
        %vedo se ci sono rappresentanti di esso
        indici_cluster=find(clusters_ind(indcl,:)==i);%trova gli indici degli indumenti di sotto-cluster i-esimo
        if(size(indici_cluster,2)>0)
            %per ogni indumento calcola la categoria, sceglie la categoria
            %più frequente e calcola la matrice di confusione del cluster
            cat = zeros(1,size(indici_cluster,2));
            for j=1:size(indici_cluster,2)
                nome=nomi_immagini_per_cluster{indcl,indici_cluster(j)};
                categoria=categoria_indumento_fn(nome,dataset_info,categories_list);
                cat(j) = categoria;
            end
            [categoria_cluster, quantita]=mode(cat);
            categorie(i)=categoria_cluster;
            confusion(i,1)=confusion(i,1)+quantita;
            confusion(i,2)=confusion(i,2)+(size(indici_cluster,2)-quantita);
        end
    end
end

figure; imagesc(confusion);colorbar
confusion_norm=zeros(maxcl,2);
for i=1:size(confusion,1)
    confusion_norm(i,:)=confusion(i,:)./(confusion(i,1)+confusion(i,2))*100;

end
figure; imagesc(confusion_norm);colorbar
valori=[50, 60, 70, 80, 90, 100];
counts=[];
num_clust_reali=size(find(confusion_norm(:,1)>0),1);
for i=1:size(valori,2)
   counts(i)= size(find(confusion_norm(:,1)>=valori(i)),1) ./ num_clust_reali *100;
end
f=figure;plot(counts, valori);xlim([87 100]);gca.XTick=([87:1:100])
ylabel('Precision %');
xlabel('%Clusters'); %%l'89% dei cluster ha precision 100%!!!!

end


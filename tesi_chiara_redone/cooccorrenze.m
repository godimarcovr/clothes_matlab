function [ cooccorrenze ] = cooccorrenze( dataset_info, clusters_ind, nomi_immagini_per_cluster, maxcl )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
cooccorrenze=zeros(maxcl, maxcl);

for i=1:size(dataset_info,1)
    if strcmp(dataset_info(i,2),'[]') == 0
        nome = dataset_info(i,1);
        [r,c]=find(strcmp(nome,nomi_immagini_per_cluster),1);
        if(~isempty([r c]))
            clusterA=clusters_ind(r,c);
            if clusterA > 0
                pairings = dataset_info(i,2);
                pairings = pairings{1};
                pairings = strsplit(pairings(2:end-1),',');
                for pairing=pairings
                    [r,c]=find(strcmp(pairing,nomi_immagini_per_cluster),1);
                    if(~isempty([r c]))
                        clusterB=clusters_ind(r,c);
                        if clusterB > 0
                            cooccorrenze(clusterA,clusterB)=cooccorrenze(clusterA,clusterB)+1;  
                            cooccorrenze(clusterB,clusterA)=cooccorrenze(clusterB,clusterA)+1;
                        end
                    end
                end
                
            end
            
        end
    end
    
end

% figure; imagesc(cooccorrenze); colorbar;


end


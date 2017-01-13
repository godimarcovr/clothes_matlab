function [cluster_abbinato,abbinamenti] = cerca_abbinamenti_fn( test_dataset_info, train_dataset_name, cluster_finale,maxcl,cooccorrenze_mat, categorie, clusters_ind, nomi_immagini_per_cluster_forma )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%Ora che so il cluster di ogni immagine, cerco il valore massimo sulla
%riga corrispondente della matrice di cooccorrenze, e restituisco il
%relativo indice, che sarà il numero del cluster che meglio si abbina

if ~exist('abbinamenti_esterni', 'dir')
    mkdir('abbinamenti_esterni');
end

cooccorrenze_mat = uint16(cooccorrenze_mat);

current_folder = pwd;
[~, test_dataset_folder, ~] = fileparts(current_folder);

tipo_abbinamenti=uint16(zeros(maxcl,1));
abbinamenti=cell(size(test_dataset_info,1),1);
cluster_abbinato=uint16(zeros(size(test_dataset_info,1),1));
for i=1:size(cluster_finale,1)
    fprintf('Calcolo abbinamenti immagine %i di %i \n',i,size(cluster_finale,1));
    if(cluster_finale(i)>0)
        cerca_indice=cluster_finale(i);
        colonne_no=[];%il cluster di forma 6 e' quello dei calzini. Io non li voglio vedere!!!!
        %[val, abbinamento]=max(cooccorrenze(cerca_indice,setdiff(1:size(cooccorrenze,2),colonne_no)));
        
        %cooccorrenze_mat
        [quanto, index]=sort(cooccorrenze_mat(cerca_indice,:),'descend');
         x=1;
        while(size(find(colonne_no(:)==index(x)),1)>0)%finchè trova indici corrispondenti a calzini, vai avanti
             x=x+1;
        end
        val=quanto(x);%quante volte occorre l'abbinamento massimo
        abbinamento=index(x);%quale cluster e' l'abbinamento massimo
        
        if(val>0)%trovato il cluster che meglio si abbina (abbinamento=numero del cluster/colonna massima delle cooccorrenze), recupero tutte le immagini di quel cluster
            %trovato il cluster che meglio si abbina, cerco un elemento di
            %test che abbia quel cluster.
            cluster_abbinato(i)=abbinamento;
            suggerito=find(cluster_finale(:)==abbinamento);
            if(size(suggerito,1)>0) %se nel testing set c'è un indumento abbinabile, suggerisce quello
                tipo_abbinamenti(i)=categorie(abbinamento);
                img = cell(size(suggerito,1)+1,1);
                img{1} = imread(strcat(test_dataset_info{i,1},'.jpg'));
                count = 1;
                for sugg=suggerito'
                    count = count + 1;
                    img{count} = imread(strcat(test_dataset_info{sugg,1},'.jpg'));
                end
                t=randperm(size(suggerito,1));
                abbinamenti{i}=test_dataset_info{suggerito(t(1))};
                
                f=figure; set(f, 'Visible', 'off');
                subplot(ceil(sqrt(size(suggerito,1)))+1,ceil(sqrt(size(suggerito,1))),1);
                imshow(img{1});
                title(strcat('test: ', num2str(cluster_finale(i))));
                for j=2:size(suggerito,1)
                    subplot(ceil(sqrt(size(suggerito,1)))+1,ceil(sqrt(size(suggerito,1))),j+1);
                    imshow(imread(strcat(test_dataset_info{suggerito(j-1),1},'.jpg')));
                    title(strcat('Cluster', num2str(cluster_finale(suggerito(j)))));
                end
                cd abbinamenti_esterni
                nomecluster=strcat(num2str(i), '.jpg');
                saveas(f,nomecluster);
                cd ..
                delete(f);
                clear f
                
            else %se nel testing set non c'è elemento abbinabile, ne suggerisce uno dal training set
                tipo_abbinamenti(i)=categorie(abbinamento);
                
                [r c]=find(clusters_ind==abbinamento);%cerco la riga (forma) e la posizione delle immagini che appartengono a quel cluster
                %coord_abbinamenti{i}=[r c];%la forma e le colonne di tutte le immagini del cluster eletto
                coord_abbinamenti = [r c];
                pos=1;
                crand=randperm(size(c,1));
                abbinamenti{i}=nomi_immagini_per_cluster_forma{coord_abbinamenti(1,1),coord_abbinamenti(crand,2)};
                
                f=figure;set(f, 'Visible', 'off');
                subplot(ceil(sqrt(size(coord_abbinamenti,1)))+1,ceil(sqrt(size(coord_abbinamenti,1))),1);
                imshow(strcat(test_dataset_info{i,1},'.jpg'));
                title(strcat('test: ', num2str(cluster_finale(i))));
                
                cd ..
                cd(train_dataset_name);
                
                for j=1:size(coord_abbinamenti,1)
                    pos=pos+1;
                    subplot(ceil(sqrt(size(coord_abbinamenti,1)))+1,ceil(sqrt(size(coord_abbinamenti,1))),pos);
                    imshow(strcat(nomi_immagini_per_cluster_forma{coord_abbinamenti(j,1),coord_abbinamenti(j,2)},'.jpg'));
                    title(strcat('Dal training ', num2str(clusters_ind(coord_abbinamenti(j,1),  coord_abbinamenti(j,2) ))));
                end
                
                cd ..
                cd(test_dataset_folder)
                
                cd abbinamenti_esterni
                nomecluster=strcat(num2str(i), '.jpg');
                saveas(f,nomecluster);
                cd ..
                delete(f);
                clear f
            end
            clear img
%             if size(abbinamenti{i},1) == 0
%                 i
%             end
            
        end
    end
end

end


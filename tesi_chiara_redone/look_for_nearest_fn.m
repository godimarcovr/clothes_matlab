function cluster_finale = look_for_nearest_fn( coppie_descrittori, test_dataset_info,labels,nomi_immagini_per_cluster_forma, train_dataset_name, forma, clusters_ind )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%per ogni immagine, cerco il descrittore-coppia più frequente e lo
%eleggo come rappresentativo della immagine
etichetta_img=zeros(size(test_dataset_info,1),2);
for i=1:size(test_dataset_info,1)
    fprintf('Calcolo rappresentante immagine %i di %i \n',i,size(test_dataset_info,1));
    tx=coppie_descrittori{i};%riga di celle (descrittori immagine)
    if(isempty(tx))
        tx=[0 0]; %se l immagine e' totalmente costituita da patch inclassificabili
    end
    [u,~,c] = unique(tx,'rows');
    [maxoccurr,itx]=max(accumarray(c,1));
    etichetta_img(i,:)=u(itx,:);
end

%cerco in labels il descrittore più vicino ad ogni immagine
cluster_finale=zeros(size(test_dataset_info,1),1);
inds=cell(size(test_dataset_info,1),1);
for i=1:size(test_dataset_info,1)
    fprintf('\nCerco l immagine piu vicina all immagine %d\n',i);
    %le etichette delle immagini con la stessa forma dal training set
    %tante righe quanti gli elementi del cluster, 2 colonne
    lab_cluster_forma=reshape(labels(forma(i),:,:),[size(labels(forma(i),:,:),2) size(labels(forma(i),:,:),3)]);
    %scopro quanti elementi effettivi ci sono andando a cercare il più
    %grande indice contenente etichette diverse da [0 0].
    num=find(~and(lab_cluster_forma(:,1)==0 , lab_cluster_forma(:,2)==0 ) , 1, 'last' );
    lab_short=lab_cluster_forma(1:num,:);%conservo solo la parte di etichette vere
    %ripeto l'etichetta più frequente per matchare la dimensione
    tmp=repmat(etichetta_img(i,:),size(lab_short,1), 1);
    %cerco gli indici dei descrittori uguali
    ind=find(and(lab_short(:,1)==etichetta_img(i,1),lab_short(:,2)==etichetta_img(i,2) ));
    %        dists=sum(abs(tmp-lab_short),2);
    %        [trash, ind]=min(dists);%trovo l'indice dell immagine col descrittore piu simile
    inds{i}=ind;
    %assegno alla immagine di test il cluster ind_esimo
    if(size(ind)>0)
        cluster_finale(i)=clusters_ind(forma(i),ind(1));%assegna al test lo stesso numero di cluster della immagine piu simile
        %[r,c]=find(clusters_ind==clusters_ind(forma(i),ind));%trova la forma(sempre uguale,r, e l indice, c, di tutte le immagini aventi quella stessa etichetta)
        %coord_simili{i}=[r c];
    else
        cluster_finale(i)=-1;
    end
end

if ~exist('clusters', 'dir')
    mkdir('clusters');
end

for i=1:size(test_dataset_info,1)
    if(cluster_finale(i)>0)
        fprintf('\nStampo compagni di cluster della immagine %d\n',i);
        pos=1;
        f=figure;set(f,'Name','Compagni di cluster immagine di test');
        set(f, 'Visible', 'off');
        subplot(ceil(sqrt(size(inds{i},1)))+1,ceil(sqrt(size(inds{i},1))),1);
        nome_immagine = strcat(test_dataset_info{i,1},'.jpg');
        img = imread(nome_immagine);
        imshow(img);
        title(strcat('Test:[',num2str(etichetta_img(i,1)),'-',num2str(etichetta_img(i,2)),']'));
        
        current_folder = pwd;
        [~, test_dataset_folder, ~] = fileparts(current_folder);
        cd ..
        cd(train_dataset_name)
        
        for j=1:size(inds{i},1)
            pos=pos+1;
            subplot(ceil(sqrt(size(inds{i},1)))+1,ceil(sqrt(size(inds{i},1))),pos);
            imshow(strcat(nomi_immagini_per_cluster_forma{forma(i),inds{i}(j)},'.jpg'));
            title(strcat('Clust:[',num2str(forma(i)),'-',num2str(labels(forma(i),inds{i}(j),1)),'-',num2str(labels(forma(i),inds{i}(j),2)),']'));
        end
        
        cd ..
        cd(test_dataset_folder)
        
        cd clusters
        nomecluster=strcat(num2str(i), '.jpg')
        saveas(f,nomecluster);
        close(f);
        cd ..
    end
end

end


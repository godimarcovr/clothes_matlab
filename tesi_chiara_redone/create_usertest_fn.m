function create_usertest_fn( test_dataset_info, train_dataset_name, test_dataset_name,clusters_ind,cluster_abbinato,cluster_finale,abbinamenti,nomi_immagini_per_cluster  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if ~exist('usertest', 'dir')
    mkdir('usertest');
end

for i=1:size(test_dataset_info,1)
    [r,c]=find(clusters_ind==cluster_abbinato(i));
    if(cluster_finale(i)>0 && cluster_abbinato(i)>0)% && r(1)~=2 && r(1)~=3 && r(1)~=8 )
        
        f=figure;
        set(f, 'Visible', 'off');
        subplot(2,2,1);
        imshow(strcat(test_dataset_info{i,2},'.jpg'));
        subplot(2,2,3);
        %controlla che esista, se non esista cerca nel trainset!
        if exist(strcat(abbinamenti{i},'.jpg'),'file')
            imshow(strcat(abbinamenti{i},'.jpg'));
        else
            cd ..
            cd(train_dataset_name)
            if exist(strcat(abbinamenti{i},'.jpg'),'file')
                imshow(strcat(abbinamenti{i},'.jpg'));
            end
            cd ..
            cd(test_dataset_name)
        end
        subplot(2,2,4);
        tmp= sum(~cellfun('isempty',nomi_immagini_per_cluster(r(1),:)));
        
        % tmp=find(size(nomi_immagini_per_cluster_forma{r(1),:},2)>0);
        col=randperm(max(tmp));
        col(1)
        while(clusters_ind(r(1),col(1))==cluster_abbinato(i))
            col=randperm(max(tmp));
        end
        
        cd ..
        cd(train_dataset_name);
        
        imshow(strcat(nomi_immagini_per_cluster{r(1), col(1)}, '.jpg'));
        
        cd ..
        cd(test_dataset_name);
        
        cd usertest
        
        nomecluster=strcat(num2str(i), '.jpg');
        saveas(f,nomecluster);
        cd ..
        close (f);
        
    end
    
end





end


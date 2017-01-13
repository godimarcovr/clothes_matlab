function confusion_testingset_fn( test_dataset_info,numcat,cluster_finale,categories_list,categorie )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
confusion_tests=zeros(numcat,numcat);
categorie_test=zeros(size(test_dataset_info,1),1);
for i=1:size(test_dataset_info,1)
    if(cluster_finale(i)>0) %se l immagine e' stata classificata
        categoria = find(not(cellfun('isempty', strfind(categories_list,test_dataset_info{i,1}))));
        if isempty(categoria)
            categoria = -1;
        else
            confusion_tests(categoria,categorie(cluster_finale(i)))=confusion_tests(categoria,categorie(cluster_finale(i)))+1;
        end
        categorie_test(i)=categoria;
        fprintf('\nCategoria test=%d, Categoria cluster=%d\n', categoria,categorie(cluster_finale(i)) );
    end
end

%% etichette sbagliate!!


%In forma logaritmica per accentuare occorrenze piccole
figure; imagesc(log(confusion_tests)+repmat(3,size(confusion_tests,1), size(confusion_tests,2)));colorbar; caxis([0,max(log(confusion_tests(:)))]);
set(gca, 'YTick',[1:1:numcat]);
set(gca,'YTickLabelMode','manual');
set(gca, 'YTickLabel',categories_list)
set(gca, 'XTick',[1:1:numcat]);
set(gca,'XTickLabelMode','manual');
set(gca,'XTickLabel',categories_list);

% %in forma normale ma partendo dal colore -2 anzichè zero per rendere
% %visibili occorrenze piccole
figure; imagesc(confusion_tests);colorbar; caxis([-2,max((confusion_tests(:)))]);
% set(gca, 'YTick',[1:1:16]);
% set(gca,'YTickLabelMode','manual');
% set(gca, 'YTickLabel',{'zaini','cappelli','occhiali','cinture','orologi','borse','calze','camicie','pantaloni','giacche','completi','cravatte','maniche lunghe', 't-shirt','cappotti','scarpe'})
% set(gca, 'XTick',[1:1:16]);
% set(gca,'XTickLabelMode','manual');
% set(gca, 'XTickLabel',{'zaini','cappelli','occhiali','cinture','orologi','borse','calze','camicie','pantaloni','giacche','completi','cravatte','maniche lunghe', 't-shirt','cappotti','scarpe'})
% 
% % stampo solo le righe che hanno almeno un'occorrenza
% figure; imagesc(confusion_tests([6 8 9 10 13 14 16], [6 8 9 10 13 14 16]));colorbar;
% set(gca, 'YTick',[1:7]);
% set(gca,'YTickLabelMode','manual');
% set(gca, 'YTickLabel',{'borse','camicie','pantaloni','giacche','maniche lunghe', 't-shirt','scarpe'})
% set(gca, 'XTick',[1:7]);
% set(gca,'XTickLabelMode','manual');
% set(gca, 'XTickLabel',{'borse','camicie','pantaloni','giacche','maniche lunghe', 't-shirt','scarpe'})
% 
% 
% %stampo la confusion normalizzata rispetto al numero di elementi del
% % cluster e rispetto al numero di indumenti dello stesso tipo esistenti
% for i=1:size(confusion_tests,1)
%     confusion_tests_norm(i,:)=confusion_tests(i,:)./sum(confusion_tests(:,i));
% end
% figure; imagesc(confusion_tests_norm([6 8 9 10 13 14 16], [6 8 9 10 13 14 16]));colorbar;
% set(gca, 'YTick',[1:11]);
% set(gca,'YTickLabelMode','manual');
% set(gca, 'YTickLabel',{'borse','camicie','pantaloni','giacche','maniche lunghe', 't-shirt','scarpe'})
% set(gca, 'XTick',[1:1:11]);
% set(gca,'XTickLabelMode','manual');
% set(gca, 'XTickLabel',{'borse','camicie','pantaloni','giacche','maniche lunghe', 't-shirt','scarpe'})
% 
% for i=1:size(confusion_tests,1)
%     confusion_tests_norm_acc(i,:)=confusion_tests(i,:)./sum(confusion_tests(i,:));
% end
% figure; imagesc(confusion_tests_norm_acc([6 8 9 10 13 14 16], [6 8 9 10 13 14 16]));colorbar;
% set(gca, 'YTick',[1:11]);
% set(gca,'YTickLabelMode','manual');
% set(gca, 'YTickLabel',{'borse','camicie','pantaloni','giacche','maniche lunghe', 't-shirt','scarpe'})
% set(gca, 'XTick',[1:1:11]);
% set(gca,'XTickLabelMode','manual');
% set(gca, 'XTickLabel',{'borse','camicie','pantaloni','giacche','maniche lunghe', 't-shirt','scarpe'})

end


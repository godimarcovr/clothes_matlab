function tipo_indumento = categoria_indumento_fn( nome, dataset_info, categories_list )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    % cerco il nome nel dataset_info nel primo campo, e trovata la cella ne prendo il
    % secondo campo, ossia la categoria principale
    cat = dataset_info{find(not(cellfun('isempty', strfind(dataset_info(:,1),nome)))),2};
    % cerco nella lista delle categorie la posizione di essa, e la ritorno
    tipo_indumento = find(not(cellfun('isempty', strfind(categories_list,cat))));
    if isempty(tipo_indumento)
        tipo_indumento = -1;
    end
end



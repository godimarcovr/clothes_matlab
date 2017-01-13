function tipo_indumento = categoria_indumento_cluster_fn( path_immagine )
%dai breadcrumbs dell'immagine, contenuti nel nome file, ricava la
%tipologia di indumento

%% ATTENZIONE: l'ordine di processamento NON e' casuale. E' stato composto 
%% dopo un attento studio su come sono strutturati i nomi file, considerando
%% che esistono nomi file come "completi_e_cravatte_cravatta_ralph_lauren_ecc...", 
%% che DEVE essere classificato come cravatta e non come completo.
%% Quindi NON modificare l'ordine degli if o la forma singolare/plurale dei
%% nomi se non sai esattamente cosa stai facendo!!
tipo_indumento=[];
i=1;
%for i=1:size(path_immagine,2)
    if(size(strfind(path_immagine,'zaini'),2)>0)
        tipo_indumento(i)=1;
    elseif(size(strfind(path_immagine,'cappelli'),2)>0)%se trova la parola camicie nel nomefile
            tipo_indumento(i)=2; 
    elseif (size(strfind(path_immagine,'occhiali'),2)>0)
            tipo_indumento(i)=3;
    elseif (size(strfind(path_immagine,'cinture'),2)>0)
            tipo_indumento(i)=4;
    elseif (size(strfind(path_immagine,'orologi'),2)>0)
            tipo_indumento(i)=5;
    elseif (size(strfind(path_immagine,'borse'),2)>0)
            tipo_indumento(i)=6;
    elseif (size(strfind(path_immagine,'calze'),2)>0 || size(strfind(path_immagine,'calzini'),2)>0)
            tipo_indumento(i)=7;
    elseif (size(strfind(path_immagine,'camicie'),2)>0)
            tipo_indumento(i)=8;
    elseif (size(strfind(path_immagine,'pantaloni'),2)>0 )
            tipo_indumento(i)=9;
    elseif (size(strfind(path_immagine,'giacche'),2)>0 || size(strfind(path_immagine,'gilet'),2)>0)
            tipo_indumento(i)=10;
    elseif (size(strfind(path_immagine,'completi-uomo'),2)>0 )
            tipo_indumento(i)=11;
    elseif (size(strfind(path_immagine,'cravatte'),2)>0)
            tipo_indumento(i)=12;
    elseif (size(strfind(path_immagine,'maniche-lunghe'),2)>0 )
            tipo_indumento(i)=13;
    elseif (size(strfind(path_immagine,'t-shirt'),2)>0)
            tipo_indumento(i)=14;
    elseif (size(strfind(path_immagine,'cappotti'),2)>0)
            tipo_indumento(i)=15;
    elseif (size(strfind(path_immagine,'scarpe'),2)>0)
            tipo_indumento(i)=16;
    elseif (size(strfind(path_immagine,'felpe'),2)>0 || size(strfind(path_immagine,'pullover'),2)>0)
            tipo_indumento(i)=13; %felpe==pullover==manichelunghe
    elseif (size(strfind(path_immagine,'jeans'),2)>0)
            tipo_indumento(i)=9; %jeans==pantaloni       
    else
        tipo_indumento(i)=-1;
    end
%end
end


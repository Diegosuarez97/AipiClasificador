function models = entrenar_models(classes)
% Calcula un model simple de descriptors per a cada classe.

models = struct('nom', {}, 'mitjana', {}, 'desviacio', {}, 'llindar', {}, 'mostres', {});

for c = 1:size(classes, 1)
    nom_classe = classes{c, 1};
    carpeta_train = classes{c, 2};
    fitxers = llistar_imatges(carpeta_train);

    descriptors = [];
    fprintf('  %s: %d imatges\n', nom_classe, numel(fitxers));

    for i = 1:numel(fitxers)
        ruta = fullfile(carpeta_train, fitxers(i).name);
        try
            img = imread(ruta);
            img_petita = reduir_imatge(img);
            bw = binaritzar(img_petita);
            props = regionprops(bw, 'Area', 'Eccentricity', 'Extent', ...
                'Solidity', 'MajorAxisLength', 'MinorAxisLength', 'Perimeter');

            if isempty(props)
                fprintf('    No detectat: %s\n', fitxers(i).name);
                continue;
            end

            [~, pos] = max([props.Area]);
            descriptors(end + 1, :) = calcular_descriptors(props(pos)); %#ok<AGROW>
        catch err
            fprintf('    Error amb %s: %s\n', fitxers(i).name, err.message);
        end
    end

    if isempty(descriptors)
        error('No hi ha descriptors per a la classe %s', nom_classe);
    end

    mitjana = mean(descriptors, 1);
    desviacio = std(descriptors, 0, 1);
    desviacio(desviacio < 0.05) = 0.05;

    distancies = distancia_descriptors(descriptors, mitjana, desviacio);
    llindar = mean(distancies) + 2.5 * std(distancies) + 0.20;

    models(c).nom = nom_classe;
    models(c).mitjana = mitjana;
    models(c).desviacio = desviacio;
    models(c).llindar = llindar;
    models(c).mostres = descriptors;

    fprintf('    Descriptor mitja: ');
    fprintf('%.3f ', mitjana);
    fprintf('\n');
end
end

function d = distancia_descriptors(desc, mitjana, desviacio)
z = (desc - mitjana) ./ desviacio;
d = sqrt(mean(z .^ 2, 2));
end

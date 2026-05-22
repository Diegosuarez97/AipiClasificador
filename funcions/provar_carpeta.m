function provar_carpeta(carpeta_test, carpeta_sortida, models)
% Classifica una carpeta de test i guarda resultats.

if ~exist(carpeta_sortida, 'dir')
    mkdir(carpeta_sortida);
end

carpeta_imatges = fullfile(carpeta_sortida, 'imatges_anotades');
carpeta_bin = fullfile(carpeta_sortida, 'binaritzades');
if ~exist(carpeta_imatges, 'dir'), mkdir(carpeta_imatges); end
if ~exist(carpeta_bin, 'dir'), mkdir(carpeta_bin); end

fitxers = llistar_imatges(carpeta_test);
resum = {};

for i = 1:numel(fitxers)
    nom_fitxer = fitxers(i).name;
    ruta = fullfile(carpeta_test, nom_fitxer);

    try
        img = imread(ruta);
        img_petita = reduir_imatge(img);
        bw = binaritzar(img_petita);
        bw = bwareaopen(bw, round(numel(bw) * 0.001));
        imwrite(uint8(bw * 255), fullfile(carpeta_bin, [netejar_nom(nom_fitxer) '_binaria.png']));

        props = regionprops(bw, 'BoundingBox', 'Centroid', 'Area', ...
            'Eccentricity', 'Extent', 'Solidity', ...
            'MajorAxisLength', 'MinorAxisLength', 'Perimeter');
        props = filtrar_blobs(props, size(bw));

        noms_detectats = cell(1, numel(props));
        colors_oset = cell(1, numel(props));

        f = figure('Visible', 'off');
        imshow(img_petita); hold on;

        for k = 1:numel(props)
            desc = calcular_descriptors(props(k));
            [nom, score] = classificar(desc, models);
            noms_detectats{k} = nom;
            colors_oset{k} = '';

            if strcmp(nom, 'Oset')
                colors_oset{k} = color_oset(img_petita, bw, props(k));
                etiqueta = sprintf('%s %s (%.2f)', nom, colors_oset{k}, score);
                color = color_de_nom(colors_oset{k});
            else
                etiqueta = sprintf('%s (%.2f)', nom, score);
                color = color_classe(nom);
            end

            rectangle('Position', props(k).BoundingBox, 'EdgeColor', color, 'LineWidth', 2);
            plot(props(k).Centroid(1), props(k).Centroid(2), '+', ...
                'Color', color, 'MarkerSize', 10, 'LineWidth', 2);
            text(props(k).BoundingBox(1), max(1, props(k).BoundingBox(2) - 12), ...
                etiqueta, 'Color', color, 'FontWeight', 'bold', ...
                'FontSize', 9, 'BackgroundColor', 'black');
        end

        title(sprintf('%s - %d objectes', nom_fitxer, numel(props)), 'Interpreter', 'none');
        hold off;

        nom_sortida = [netejar_nom(nom_fitxer) '_detectat.png'];
        exportgraphics(f, fullfile(carpeta_imatges, nom_sortida), 'Resolution', 140);
        close(f);

        resum(end + 1, :) = {nom_fitxer, numel(props), ...
            sum(strcmp(noms_detectats, 'Oset')), ...
            sum(strcmp(noms_detectats, 'JocDS')), ...
            sum(strcmp(noms_detectats, 'Cullera')), ...
            sum(strcmp(noms_detectats, 'Desconegut')), ...
            strjoin(colors_oset(~cellfun('isempty', colors_oset)), ', ')};

        fprintf('  %2d/%2d  %s -> %d objectes\n', i, numel(fitxers), nom_fitxer, numel(props));
    catch err
        fprintf('  Error amb %s: %s\n', nom_fitxer, err.message);
    end
end

T = cell2table(resum, 'VariableNames', ...
    {'Arxiu', 'Objectes', 'Oset', 'JocDS', 'Cullera', 'Desconegut', 'Colors_oset'});
writetable(T, fullfile(carpeta_sortida, 'resum.csv'));
end

function props_ok = filtrar_blobs(props, mida)
props_ok = props([]);
area_min = numel(zeros(mida)) * 0.001;
area_max = numel(zeros(mida)) * 0.80;

for i = 1:numel(props)
    if props(i).Area >= area_min && props(i).Area <= area_max
        props_ok(end + 1) = props(i);
    end
end
end

function [nom, millor_score] = classificar(desc, models)
millor_score = inf;
millor_pos = 1;

for i = 1:numel(models)
    z = (desc - models(i).mitjana) ./ models(i).desviacio;
    d = sqrt(mean(z .^ 2));
    score = d / models(i).llindar;

    if score < millor_score
        millor_score = score;
        millor_pos = i;
    end
end

if millor_score <= 1.80
    nom = models(millor_pos).nom;
else
    nom = 'Desconegut';
end
end

function color = color_classe(nom)
switch nom
    case 'Oset'
        color = [0.0 0.8 1.0];
    case 'JocDS'
        color = [1.0 0.7 0.0];
    case 'Cullera'
        color = [0.0 0.9 0.2];
    otherwise
        color = [1.0 1.0 1.0];
end
end

function nom_color = color_oset(img, bw, prop)
% Extra senzill: mirem els pixels amb mes color dins del blob.
if size(img, 3) ~= 3
    nom_color = 'transparent';
    return;
end

mask = false(size(bw));
x1 = max(1, floor(prop.BoundingBox(1)));
y1 = max(1, floor(prop.BoundingBox(2)));
x2 = min(size(bw, 2), ceil(prop.BoundingBox(1) + prop.BoundingBox(3)));
y2 = min(size(bw, 1), ceil(prop.BoundingBox(2) + prop.BoundingBox(4)));
mask(y1:y2, x1:x2) = bw(y1:y2, x1:x2);

hsv_img = rgb2hsv(img);
h_vals = hsv_img(:,:,1);
s_vals = hsv_img(:,:,2);
v_vals = hsv_img(:,:,3);

% Si l'objecte és transparent, només agafa una mica de color per la llum.
% Per això demanem bastants píxels amb saturació clara.
mask_color = mask & s_vals > 0.35 & v_vals > 0.20;
part_color = nnz(mask_color) / max(nnz(mask), 1);

if part_color < 0.18
    nom_color = 'transparent';
    return;
end

if nnz(mask_color) > 0
    h = median(h_vals(mask_color));
    s = median(s_vals(mask_color));
    v = median(v_vals(mask_color));
else
    nom_color = 'transparent';
    return;
end

if v < 0.25 || s < 0.35
    nom_color = 'transparent';
elseif h < 0.04 || h >= 0.94
    nom_color = 'vermell';
elseif h < 0.12
    nom_color = 'taronja';
elseif h < 0.18
    nom_color = 'groc';
elseif h < 0.50
    nom_color = 'verd';
else
    nom_color = 'transparent';
end
end

function color = color_de_nom(nom_color)
switch nom_color
    case 'vermell'
        color = [1.0 0.1 0.1];
    case 'taronja'
        color = [1.0 0.45 0.0];
    case 'groc'
        color = [1.0 0.85 0.0];
    case 'verd'
        color = [0.1 0.8 0.1];
    otherwise
        color = [0.0 0.9 1.0];
end
end

function nom = netejar_nom(nom)
nom = strrep(nom, '.', '_');
nom = strrep(nom, ' ', '_');
nom = strrep(nom, '(', '');
nom = strrep(nom, ')', '');
end

function fer_grafics_simple(carpeta_resultats)
% Fa uns grafics senzills per posar a la memòria.

if nargin < 1
    carpeta_resultats = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'resultats');
end

carpeta_grafics = fullfile(carpeta_resultats, 'grafics');
if ~exist(carpeta_grafics, 'dir')
    mkdir(carpeta_grafics);
end

fitxer_models = fullfile(carpeta_resultats, 'models_simples.mat');
if exist(fitxer_models, 'file') ~= 2
    warning('No trobo models_simples.mat. Primer executa projecte_aipi_simple.');
    return;
end

dades = load(fitxer_models);
models = dades.models;

grafic_descriptors(models, carpeta_grafics);
grafic_comptatge(carpeta_resultats, carpeta_grafics);
grafic_colors_osset(carpeta_resultats, carpeta_grafics);

fprintf('Grafics guardats a resultats/grafics\n');
end

function grafic_descriptors(models, carpeta_grafics)
noms_desc = {'Eccentricity', 'Extent', 'Solidity', 'Aspecte', 'Circularitat'};
M = vertcat(models.mitjana);

f = figure('Visible', 'off');
bar(M);
grid on;
set(gca, 'XTickLabel', {models.nom});
legend(noms_desc, 'Location', 'bestoutside');
title('Descriptors mitjans de cada classe');
ylabel('Valor mitja');
exportgraphics(f, fullfile(carpeta_grafics, 'descriptors_mitjans.png'), 'Resolution', 140);
close(f);

f = figure('Visible', 'off');
hold on;
for i = 1:numel(models)
    punts = models(i).mostres;
    scatter(punts(:,1), punts(:,4), 35, 'filled');
end
grid on;
xlabel('Eccentricity');
ylabel('Relacio eix major / eix menor');
legend({models.nom}, 'Location', 'best');
title('Separacio de classes amb dos descriptors');
hold off;
exportgraphics(f, fullfile(carpeta_grafics, 'dispersio_classes.png'), 'Resolution', 140);
close(f);
end

function grafic_comptatge(carpeta_resultats, carpeta_grafics)
classes = {'Oset', 'JocDS', 'Cullera'};
total_objectes = zeros(1, numel(classes));
total_desconeguts = zeros(1, numel(classes));

for i = 1:numel(classes)
    fitxer = fullfile(carpeta_resultats, classes{i}, 'resum.csv');
    if exist(fitxer, 'file') == 2
        T = readtable(fitxer);
        total_objectes(i) = sum(T.Objectes);
        total_desconeguts(i) = sum(T.Desconegut);
    end
end

f = figure('Visible', 'off');
bar([total_objectes; total_desconeguts]');
grid on;
set(gca, 'XTickLabel', classes);
legend({'Objectes detectats', 'Desconeguts'}, 'Location', 'best');
title('Resum de deteccions en les imatges de test');
ylabel('Nombre');
exportgraphics(f, fullfile(carpeta_grafics, 'resum_deteccions.png'), 'Resolution', 140);
close(f);
end

function grafic_colors_osset(carpeta_resultats, carpeta_grafics)
fitxer = fullfile(carpeta_resultats, 'Oset', 'resum.csv');
if exist(fitxer, 'file') ~= 2
    return;
end

T = readtable(fitxer, 'TextType', 'string');
colors = strings(0);

for i = 1:height(T)
    txt = T.Colors_oset(i);
    if strlength(txt) == 0
        continue;
    end
    parts = split(txt, ',');
    parts = strtrim(parts);
    colors = [colors; parts]; 
end

if isempty(colors)
    return;
end

noms = unique(colors);
comptes = zeros(size(noms));
for i = 1:numel(noms)
    comptes(i) = sum(colors == noms(i));
end

f = figure('Visible', 'off');
bar(comptes);
grid on;
set(gca, 'XTickLabel', cellstr(noms));
title('Colors detectats en els ossets');
ylabel('Nombre aproximat');
exportgraphics(f, fullfile(carpeta_grafics, 'colors_ossets.png'), 'Resolution', 140);
close(f);
end

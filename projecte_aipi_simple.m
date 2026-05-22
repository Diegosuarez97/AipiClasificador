function projecte_aipi_simple()
% PROJECTE_AIPI_SIMPLE
% Practica d'analisi d'imatges: deteccio i classificacio de tres objectes.
%
% Objectes utilitzats:
%   - Oset
%   - JocDS
%   - Cullera
%
% Passos:
%   1) Entrenar amb imatges de cada objecte.
%   2) Classificar les imatges de test.
%   3) Guardar imatges anotades, binaritzades, CSV i grafics.

clc; close all;

carpeta_projecte = fileparts(mfilename('fullpath'));
addpath(fullfile(carpeta_projecte, 'funcions'));

carpeta_data = fullfile(carpeta_projecte, 'data');
carpeta_resultats = fullfile(carpeta_projecte, 'resultats');

if ~exist(carpeta_resultats, 'dir')
    mkdir(carpeta_resultats);
end

classes = {
    'Oset',    fullfile(carpeta_data, 'osos_color', 'Entrenamiento_oso'),  fullfile(carpeta_data, 'osos_color', 'Test_oso');
    'JocDS',   fullfile(carpeta_data, 'juegos', 'Entrenamietno_juego'),    fullfile(carpeta_data, 'juegos', 'Test_juegos');
    'Cullera', fullfile(carpeta_data, 'cuchara', 'Entrenamiento_cuchara'), fullfile(carpeta_data, 'cuchara', 'Test_cuchara')
};

fprintf('PROJECTE AIPI - VERSIO SIMPLE\n');
fprintf('=============================\n\n');

fprintf('Entrenant amb les imatges...\n');
models = entrenar_models(classes);
save(fullfile(carpeta_resultats, 'models_simples.mat'), 'models');
fprintf('\nModels guardats a resultats/models_simples.mat\n\n');

for i = 1:size(classes, 1)
    nom_classe = classes{i, 1};
    carpeta_test = classes{i, 3};
    carpeta_sortida = fullfile(carpeta_resultats, nom_classe);

    fprintf('Test: %s\n', nom_classe);
    provar_carpeta(carpeta_test, carpeta_sortida, models);
    fprintf('\n');
end

fer_grafics_simple(carpeta_resultats);
fprintf('Acabat. Mira la carpeta resultats.\n');
end

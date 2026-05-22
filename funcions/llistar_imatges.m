function fitxers = llistar_imatges(carpeta)
% Retorna les imatges d'una carpeta.

extensions = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff', '*.heic'};
fitxers = [];

for i = 1:numel(extensions)
    fitxers = [fitxers; dir(fullfile(carpeta, extensions{i}))];
end
end

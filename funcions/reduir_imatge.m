function img2 = reduir_imatge(img)
% Redueix imatges grans per treballar mes rapid.

max_pixels = 900;
mida = size(img);
escala = min(1, max_pixels / max(mida(1), mida(2)));

if escala < 1
    img2 = imresize(img, escala);
else
    img2 = img;
end
end

function bw = binaritzar(img)
% Passa una imatge a binaria i neteja una mica la mascara.

if size(img, 3) == 3
    gris = rgb2gray(img);
else
    gris = img;
end

gris = imgaussfilt(gris, 1.2);
nivell = graythresh(gris);
bw = imbinarize(gris, nivell);

% Normalment el fons queda blanc. Si passa això, invertim.
if mean(bw(:)) > 0.50
    bw = ~bw;
end

bw = imclose(bw, strel('disk', 5));
bw = imfill(bw, 'holes');
bw = imopen(bw, strel('disk', 3));
bw = bwareaopen(bw, round(numel(bw) * 0.0008));
end

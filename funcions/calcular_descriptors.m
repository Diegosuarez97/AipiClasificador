function desc = calcular_descriptors(prop)
% Descriptors de forma utilitzats per classificar.

aspecte = prop.MajorAxisLength / max(prop.MinorAxisLength, 1);
circularitat = 4 * pi * prop.Area / max(prop.Perimeter ^ 2, 1);

desc = [
    prop.Eccentricity, ...
    prop.Extent, ...
    prop.Solidity, ...
    aspecte, ...
    circularitat
];
end

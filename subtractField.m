function [subtracted] = subtractField(FGfield, BGfield)

FGfield = imgaussfilt3(FGfield, 2);
BGfield = imgaussfilt3(BGfield, 2);

for i = 1:size(FGfield, 3)
    BGfield(:, :, i) = stabilizePair(FGfield(:, :, i), BGfield(:, :, i));
end

subtracted = single((double(FGfield) - double(BGfield)) ./ double(BGfield) * 100);
subtracted(isnan(subtracted)) = 0;
subtracted(isinf(subtracted)) = 0;

return;
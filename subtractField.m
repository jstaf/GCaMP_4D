function [subtracted] = subtractField(FGfield, BGfield)

% align
for i = 1:size(FGfield, 3)
    BGfield(:, :, i) = stabilizePair(FGfield(:, :, i), BGfield(:, :, i));
end

% gaussfilter
FGfield = imgaussfilt3(FGfield, 2);
BGfield = imgaussfilt3(BGfield, 2);

% subtract fields and wipe division by 0 errors
subtracted = single((double(FGfield) - double(BGfield)) ./ double(BGfield) * 100);
subtracted(isnan(subtracted)) = 0;
subtracted(isinf(subtracted)) = 0;

% We are going to wipe the top and bottom planes as they would see a
% significant dff if the field shook at all in the Z dimension.
subtracted(:, :, [1, end]) = 0;

return;
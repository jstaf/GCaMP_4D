function [deltaField] = subtractField(FGfield, BGfield, ver)
% 3d field subtraction code

% align
progressBar = waitbar(0, 'Aligning and subtracting image passes');
depth = size(FGfield, 3);
for i = 1:depth
    [BGfield(:, :, i), success] = stabilizePair(FGfield(:, :, i), BGfield(:, :, i));
    waitbar(i/(depth + 1), progressBar);
    
%     % debugging
%     if ~success
%         fprintf([num2str(i), '.']);
%     end
end
% debugging
fprintf('\n')

% gaussfilter
if ver < 8.5
    % have to individually filter every plane... boooooooo...
    gauss = fspecial('gaussian', 7, 2);
    for i = 1:size(FGfield, 3)
        FGfield(:, :, i) = imfilter(FGfield(:, :, i), gauss);
        BGfield(:, :, i) = imfilter(BGfield(:, :, i), gauss);
    end
else
    FGfield = imgaussfilt3(FGfield, 2);
    BGfield = imgaussfilt3(BGfield, 2);
end

% subtract fields and wipe division by 0 errors
deltaField = single((double(FGfield) - double(BGfield)) ./ double(BGfield) * 100);
deltaField(isnan(deltaField)) = 0;
deltaField(isinf(deltaField)) = 0;

% We are going to wipe the top and bottom planes as they would see a
% significant dff if the field shook at all in the Z dimension.
deltaField(:, :, [1, end]) = 0;
close(progressBar);

return;
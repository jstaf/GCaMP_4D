function [deltaIMG] = subtractImg(foreground, background)

foreground = imgaussfilt(foreground, 2);
background = imgaussfilt(background, 2);

deltaIMG = double(foreground) ./ double(background);

deltaIMG = (deltaIMG * 100) - 100; %change to percent delta

% fix division by 0 artifacts
deltaIMG(isnan(deltaIMG(:))) = 0;
deltaIMG(isinf(deltaIMG(:))) = 0;

return;
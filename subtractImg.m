function [deltaIMG] = subtractImg(foreground, background)

% not compatible with older versions of MATLAB
%foreground = imgaussfilt(foreground, 2);
%background = imgaussfilt(background, 2);

% for compatibility with 2013b
gauss = fspecial('gaussian', 7, 2);
foreground = imfilter(foreground, gauss);
background = imfilter(background, gauss);

% new formula
deltaIMG = (double(foreground) - double(background)) ./ double(background) * 100;

% fix division by 0 artifacts
deltaIMG(isnan(deltaIMG(:))) = 0;
deltaIMG(isinf(deltaIMG(:))) = 0;

return;
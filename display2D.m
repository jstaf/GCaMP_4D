function display2D(handles)
% displays the data in flat form

FG = handles.confocalStack(:, :, :, get(handles.FGselect, 'Value'));
if (handles.backgroundOn)
    % new subtraction code
    BG = handles.confocalStack(:, :, :, get(handles.BGselect,'Value'));
    FG = subtractField(FG, BG, handles.ver);
    image = max(FG, [], 3);
    % have to filter again or it looks very meh
    if handles.ver < 8.5
        gauss = fspecial('gaussian', 3, 1);
        image = imfilter(image, gauss);
    else
        image = imgaussfilt(image, 1);
    end
else
    image = max(FG, [], 3);
end

percentileHI = quantile(image(:), 0.999);
percentileLO = quantile(image(:), 0.01);
imshow(image, [percentileLO, percentileHI]);

% create colorbar and its limits
warning('off','MATLAB:warn_r14_stucture_assignment');
if (handles.backgroundOn)
    colormap('jet');
    colorBAR = colorbar('EastOutside');
    colorBAR.Label.String = 'Change in fluorescence (dF/F)';
else
    colormap('gray');
    colorBAR = colorbar('EastOutside');
    colorBAR.Label.String = 'Raw fluorsecence value';
end
drawnow;
return;
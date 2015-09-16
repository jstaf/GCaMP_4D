function handles = display2D(hObject, handles)
% displays the data in flat form

% preprocess, generate correct 3D FG field for display
FG = handles.confocalStack(:, :, :, get(handles.FGselect, 'Value'));
if (handles.backgroundOn)
    % new subtraction code
    BG = handles.confocalStack(:, :, :, get(handles.BGselect,'Value'));
    FG = subtractField(FG, BG, handles.ver);
end

% now do we want the max projection or just a slice of it
if handles.mode == 1
    if ~handles.backgroundOn
        image = max(FG, [], 3);
    else
        [image] = max(FG, [], 3);
        [imageMin] = min(FG, [], 3);
        
        for p = 1:numel(image)
            if image(p) < abs(imageMin(p))
                image(p) = imageMin(p);
            end
        end
    end
else
    % per slice view
    slice = ceil((handles.Y_Angle + 90) / 180 * size(FG, 3));
    if (slice < 1) % only if slider goes to 0
        slice = 1; 
    end
    image = FG(:, :, slice);
    image = insertText(image, [10, 10], ...
        [num2str(slice), ' / ', num2str(size(FG, 3))], ...
        'BoxColor', [255,255,255]);
end

if handles.backgroundOn
    % have to filter again or it looks very meh
    if handles.ver < 8.5
        gauss = fspecial('gaussian', 3, 1);
        image = imfilter(image, gauss);
    else
        image = imgaussfilt(image, 1);
    end
end

imshow(image, [handles.filterMin, handles.filterMax]);

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

% update handles with the display image for the autoscale function
handles.displayImage = image;
guidata(hObject, handles);

return;
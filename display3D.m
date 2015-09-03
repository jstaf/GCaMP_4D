function display3D(handles, dataReduce)
% Display 3D image for plotting

if handles.backgroundOn
    % field subtraction
    image3d = subtractField(handles.confocalStack(:, :, :, get(handles.FGselect, 'Value')), ...
        handles.confocalStack(:, :, :, get(handles.BGselect, 'Value')), handles.ver);    
else
    % straight up 3d image
    image3d = handles.confocalStack(:, :, :, get(handles.FGselect, 'Value'));
    if handles.ver < 8.5
        % looks worse for earlier versions, sorry
        gauss = fspecial('gaussian', 7, 2);
        for i = 1:size(image3d, 3);
            image3d(:, :, i) = imfilter(image3d(:, :, i), gauss);
        end
    else
        image3d = imgaussfilt3(image3d, 1);
    end
end
sliceProject(image3d, handles.alphaMod, handles.voxelSizes, dataReduce, handles.ver);
view(handles.X_Angle, handles.Y_Angle);
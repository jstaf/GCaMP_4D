function display3D(handles, dataReduce)
% Display 3D image for plotting

if handles.backgroundOn
    image3d = subtractField(handles.confocalStack(:, :, :, get(handles.FGselect, 'Value')), ...
        handles.confocalStack(:, :, :, get(handles.BGselect, 'Value')));    
else
    image3d = handles.confocalStack(:, :, :, get(handles.FGselect, 'Value'));
    image3d = imgaussfilt3(image3d, 1);
end
sliceProject(image3d, handles.alphaMod, handles.voxelSizes, dataReduce);
view(handles.X_Angle, handles.Y_Angle);
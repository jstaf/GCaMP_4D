function autoscale(hObject, handles, image, quantileLO, quantileHI)
% determine if autoscaling is needed and autoscale.

if handles.filterMin >= handles.filterMax
    disp('Invalid value - autoscaling enabled.');
    handles.autoscaleOn = true;
    set(handles.autoscaleSet, 'Value', true);
end
if handles.autoscaleOn
    handles.filterMin = round(quantile(image(:), quantileLO));
    handles.filterMax = round(quantile(image(:), quantileHI));
    set(handles.filterMinSet, 'String', num2str(handles.filterMin));
    set(handles.filterMaxSet, 'String', num2str(handles.filterMax));
end
guidata(hObject, handles);
caxis([handles.filterMin, handles.filterMax])

return;

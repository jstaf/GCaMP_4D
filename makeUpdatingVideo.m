function makeUpdatingVideo(videoName, image4d)

% x/y/z/time
viewField = image4d(:, :, :, 1);

% we need to do this before making a video
writer = VideoWriter(videoName);
writer.FrameRate = 10;
open(writer);
waitDialog = waitbar(0, 'Creating video...');
dimensions = size(image4d);
for stackNum = 2:dimensions(4)
    for imageNum = 1:dimensions(3)
        
        viewField(:, :, imageNum) = image4d(:, :, imageNum, stackNum);
        frame = max(viewField, [], 3);
        writeVideo(writer, frame);
    end
end
% cleaning up
close(writer);
close(waitDialog);

return;
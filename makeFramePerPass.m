function makeFramePerPass(videoName, image3d)

% we need to do this before making a video
writer = VideoWriter(videoName);
writer.FrameRate = 1;
open(writer);
waitDialog = waitbar(0, 'Creating video...');
timesThruStack = size(image3d, 3);
for frameNum = 1:timesThruStack
    waitbar(frameNum/timesThruStack, waitDialog, ...
        strcat({'Writing frame'},{' '}, num2str(frameNum), {' '}, {'of'}, {' '}, num2str(timesThruStack)));
    frame = image3d(:, :, frameNum);
    
    writeVideo(writer, frame);
end
% cleaning up
close(writer);
close(waitDialog);

return;
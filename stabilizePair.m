function [image2warp, success] = stabilizePair(image1, image2)

% lets take a crack at stabilizing the image...

% note: I claim no authorship of this function, as I am just copying the
% MATLAB tutorial at http://www.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html

const = 4;
image1c = image1 * const;
image2c = image2 * const;

% went with SURF features because it gave the most points on my test images
corners1 = detectSURFFeatures(image1c);
corners2 = detectSURFFeatures(image2c);

[features1, points1] = extractFeatures(image1c, corners1);
[features2, points2] = extractFeatures(image2c, corners2);

pairs = matchFeatures(features1, features2);
points1 = points1(pairs(:, 1), :);
points2 = points2(pairs(:, 2), :);

if (size(pairs, 1) > 5)
    [transform] = estimateGeometricTransform(points2, points1, 'affine');
    image2warp = imwarp(image2, transform, 'OutputView', imref2d(size(image2)));
    success = 1;
else
    success = 0;
    image2warp = image2;
end

return;





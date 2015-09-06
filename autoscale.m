function [min, max] = autoscale(image, quantileLO, quantileHI)
% determine if autoscaling is needed and autoscale.

min = round(quantile(image(:), quantileLO));
max = round(quantile(image(:), quantileHI));

return;

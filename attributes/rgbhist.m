function varargout = rgbhist(I)
%RGBHIST Histogram of RGB values.

I = imread(I);

if (size(I, 3) ~= 3)
error('rgbhist:numberOfSamples', 'Input image must be RGB.')
end

nBins = 256;

rHist = imhist(I(:,:,1), nBins);
gHist = imhist(I(:,:,2), nBins);
bHist = imhist(I(:,:,3), nBins);

%hFig = figure;

figure
subplot(1,2,1);imshow(I)
subplot(1,2,2);

h(1) = stem(1:256, rHist); hold on
h(2) = stem(1:256 + 1/3, gHist);
h(3) = stem(1:256 + 2/3, bHist);
hold off

set(h, 'marker', 'none')
set(h(1), 'color', [1 0 0])
set(h(2), 'color', [0 1 0])
set(h(3), 'color', [0 0 1])
axis square 
end
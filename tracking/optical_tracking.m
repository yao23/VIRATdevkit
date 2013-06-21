function currbbox = optical_tracking(flowx,flowy,bbox)
% Deciding % of area we want to track
areaper = 0.5;

% Dividing flowx and flowy by block area to get per pixel flow
bbox = [bbox(1:2),bbox(1:2)+bbox(3:4)];

scale = 0.5;
% Data that matters for current person
intbbox = [bbox(1)+(0.5*(1-areaper)*(bbox(3)-bbox(1))),...
    bbox(2)+(0.5*(1-areaper)*(bbox(4)-bbox(2))),...
    bbox(3)-(0.5*(1-areaper)*(bbox(3)-bbox(1))),...
    bbox(4)-(0.5*(1-areaper)*(bbox(4)-bbox(2)))]*scale;
xrange = ceil(intbbox(1)):floor(intbbox(3));
yrange = ceil(intbbox(2)):floor(intbbox(4));

xn = sum(sum(abs(flowx(yrange,xrange))>0));
yn = sum(sum(abs(flowy(yrange,xrange))>0));

if xn~=0
    vx = (sum(sum(flowx(yrange,xrange)))/(xn))/scale;
else
    vx = 0;
end
if yn~=0
    vy = (sum(sum(flowy(yrange,xrange)))/(length(xrange)*length(yrange)))/scale;
else
    vy = 0;
end

% Update Bounding box
currbbox = zeros(1,4);
currbbox(1,1) = bbox(1)+vx;
currbbox(1,2) = bbox(2)+vy;
currbbox(1,3) = bbox(3)-bbox(1);
currbbox(1,4) = bbox(4)-bbox(2);
end

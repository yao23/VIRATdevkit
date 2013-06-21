function trackeddata = grouptrack(humbbox,currentinddata)
% Finds the maximum area to be covered to by a group
minratio = 0.1;
areaint = rectint(currentinddata,humbbox);
areatrackbbox = prod(currentinddata(3:4));
areahumbbox = humbbox(:,3).*humbbox(:,4);
totalarea = repmat(areatrackbbox,1,size(areaint,2))+repmat(areahumbbox',size(areaint,1),1)-areaint;
pascalratiomat = areaint./totalarea;
ind = find(pascalratiomat>minratio);
intersectxy = zeros(length(ind),4);
for i = 1:length(ind)
    intersectxy(i,:) = [humbbox(ind(i),1:2),humbbox(ind(i),1:2)+humbbox(ind(i),3:4)];
end
xmin = min(intersectxy(:,1));
ymin = min(intersectxy(:,2));
xmax = max(intersectxy(:,3));
ymax = max(intersectxy(:,4));
trackeddata = [xmin,ymin,xmax-xmin,ymax-ymin];
end
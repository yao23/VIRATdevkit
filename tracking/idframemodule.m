function idframe = idframemodule(hbboxdata_od,framenum,maxframes)
% Collosion by two humans handling module

    dist12 = zeros((maxframes-framenum),2);
    for i = framenum:maxframes
        if length(find(hbboxdata_od(i,:))) > 5 & length(find(hbboxdata_od(i,:))) < 9
%             There are two persons in this video
            box1 = hbboxdata_od(i,1:4);
            box1 = [box1(1:2) box1(1:2)+box1(3:4)];
            box2 = hbboxdata_od(i,5:8);
            box2 = [box2(1:2) box2(1:2)+box2(3:4)];
%             Storing seperation in x dir
            if (box1(1) - box2(1)) < 0
%                 Box2 lies to the right of box1
                dist12(i,1) = box2(1) - box1(3);
            else
%                 Box2 lies to left of box1
                dist12(i,1) = box1(1) - box2(3);
            end
%             Storing seperation in y dir
            if (box1(2) - box2(2)) < 0
%                 Box2 lies to down of box1
                dist12(i,2) = box2(2) - box1(4);
            else
%                 Box2 lies to top of box1
                dist12(i,1) = box1(2) - box2(4);
            end
        end
    end
    
 %   Detecting the best frame to start after collision multiple tracking
 [maxdist,idframe] = max(dist12(:,1));
 if (maxdist == 0)
     % Which means there were never two seperate human detections again
    idframe = maxframes+1;
 end


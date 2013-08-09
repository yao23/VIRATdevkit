% Apply nms on detection and return the indices corresponding to smaller of
% the bounding box
function nind = detections_nms(det,ind)
% Default return 
nind = ind;
% Pascal ratio measure to justify the integration of bounding boxes
minareathresh = 0.3;
% Getting the collection of all the bounding boxes
bboxes = zeros(length(ind),4);
for i  = 1:length(ind)
    bboxes(i,:) = det((ind(i)-1)*4+1:ind(i)*4);
end
areainteg =  rectint(bboxes,bboxes);
% Picking out the third and fourth element of datamatrix and same for
% detections to get pascal ratio
areamat = repmat((bboxes(:,3:4:end).*bboxes(:,4:4:end)),1,size(bboxes,1))+...
    repmat((bboxes(:,3:4:end).*bboxes(:,4:4:end))',size(bboxes,1),1);
areadisjoint = areamat-areainteg;
pascalratiomat = areainteg./areadisjoint;

% Sorting pascalratiomat for assigning detections
% Getting all the overlapping detection - upper diagonal matrix
req_mat = triu(pascalratiomat,1);
% Storing all the indices that are not required
nreq_ind = [];
if (max(max(req_mat))>minareathresh)
    % We have some overlapping detections that we need to remove
    [row,col] = find(req_mat);
    % Processing all these indices to determine the right indices
    for i = 1:length(row)
        % Checking which bounding box size is smaller
        if prod(bboxes(row,3:4))>prod(bboxes(col,3:4))
            % Need to reject the bigger box
            nreq_ind = [nreq_ind;ind(row)];
        else
            nreq_ind = [nreq_ind;ind(col)];
        end
    end
end
% Doing set subtraction to return non-intersecting indices
if ~isempty(nreq_ind)
    nind = setdiff(ind,nreq_ind);
end

end
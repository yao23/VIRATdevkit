function [datamatrix,statematrix,currentscene] = exit_decision(datamatrix,statematrix,framenum,fb,currentscene,im)
for class = 1:length(datamatrix)
    trackedsildata = datamatrix{class}(framenum,:);
    for i = 1:length(datamatrix{class}(framenum-fb,:))/4
        % Getting all the tracked entities
        %if statematrix{class}(framenum,i)==3
        boxcor = trackedsildata(1+4*(i-1):4*i)';
        if boxcor(3)>0 && boxcor(4)>0
            exitdecision = 0;
            if (boxcor(1)<=0 || boxcor(2)<=0 || (boxcor(3)+boxcor(1))>=size(im,2) ||...
                    (boxcor(2)+boxcor(4))>=size(im,1))
                % Finding the box when it was first detected
                pfind = find(statematrix{class}(1:framenum,i)==4,1,'Last');
                % Previous box
                pfbox = datamatrix{class}(pfind,1+4*(i-1):4*i);
                boxcor = [((boxcor(1:2)>0).*boxcor(1:2))+[1;1];...
                    (boxcor(3:4)+boxcor(1:2)>[size(im,2); size(im,1)]).*[size(im,2); size(im,1)]+...
                    (boxcor(3:4)+boxcor(1:2)<=[size(im,2); size(im,1)]).*(boxcor(3:4)+boxcor(1:2))];
                testbox = [boxcor(1:2);boxcor(3:4)-boxcor(1:2)]';
                % If current area is less then 50% the original area
                if prod(testbox(3:4))<=0.7*prod(pfbox(3:4))
                    exitdecision = 1;
                end
                % Assign the truncated box size to the tracked results
                datamatrix{class}(framenum,1+4*(i-1):4*i) = testbox;
                
                
                
                if exitdecision
                    statematrix{class}(framenum:end,i) = 1;
                    datamatrix{class}(framenum,(i-1)*4+1:i*4) = zeros(1,4);
                    % This entry of object has to be removed from datamatrix and
                    % currentscene
                    %if length(currentscene) > 1
                    % currentscenenew = zeros(length(currentscene)-1,1);
                    % if i>1
                    %    datamatrix{class}(framenum,(i-1)*4+1:i*4) = zeros(1,4);
                    %    statematrix{class}(framenum:end,i) = ones(size(statematrix{class},1)-framenum+1,1);
                    % else
                    %     datamatrix{class}(framenum,(i-1)*4+1:i*4) = zeros(1,4);
                    %     statematrix{class}(framenum:end,1) = ones(size(statematrix{class},1)-framenum+1,1);
                    % end
                    %else
                    %     currentscene{class} = [];
                    %end
                end
                %end
            end
        end
    end
end
end
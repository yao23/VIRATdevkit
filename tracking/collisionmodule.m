function [id1,id2] = collisionmodule(videoobj,datamatrix,data,...
    lastbestdetect1,lastbestdetect2,testdata1,testdata2,endframe)

id1counter1 = 0;
id2counter1 = 0;
for i = 0:(size(testdata1)-1)
    inputframeno = lastbestdetect1;
    testframeno = endframe-i;
    inpbbox = datamatrix(lastbestdetect1,2:5);
    testbbox = [testdata1(end-i,:);testdata2(end-i,:)];
    [match,~] = histmatch(videoobj,data,inputframeno,testframeno,inpbbox,testbbox);
    if match == 1
        id1counter1 = id1counter1+1;
    else
        id2counter1 = id2counter1+1;
    end
end

id1counter2 = 0;
id2counter2 = 0;
for i = 0:(size(testdata2)-1)
    inputframeno = lastbestdetect2;
    testframeno = endframe-i;
    inpbbox = datamatrix(lastbestdetect2,6:9);
    testbbox = [testdata1(end-i,:);testdata2(end-i,:)];
    [match,~] = histmatch(videoobj,data,inputframeno,testframeno,inpbbox,testbbox);
    if match == 1
        id1counter2 = id1counter2+1;
    else
        id2counter2 = id2counter2+1;
    end
end

if (id1counter1-id1counter2)>(id2counter1-id2counter2)
    id1 = 1;id2 = 2;
else
    id1 = 2; id2 = 1;
end
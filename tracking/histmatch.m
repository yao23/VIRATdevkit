function [match,euclideanscore] = histmatch(framedir,data,inputframeno,testframeno,inpbbox,testbbox)

% Matches patches in inputframe and testframe given bouding boxes in both
% the frames
inputresolution = 0.5;
% Constants
histscorethresh = 0.2;
inpbbox = floor(inpbbox*inputresolution);
testbbox = floor(testbbox*inputresolution);

% Initializing scores
euclideanscore = zeros(size(inpbbox,1),size(testbbox,1));
% klscore = zeros(size(inpbbox,1),size(testbbox,1));

for i=1:size(inpbbox,1)
    % Calculating bgsubtracted rbg image of input frame
    inputframebs = permute(data(:,:,:,inputframeno(i)),[4 2 3 1]);
    inputframebs = permute(inputframebs,[3 2 1]);
    inputframebs = double(inputframebs(inpbbox(i,2)+1:inpbbox(i,2)+inpbbox(i,4),...
                                       inpbbox(i,1)+1:inpbbox(i,1)+inpbbox(i,3)));
    imagerep = repmat(inputframebs,[1,1,3]);
    imname = sprintf('frame_%05d.png',inputframeno(i));
    inputframe = imread([framedir '/' imname]);
    %inputframe = read(videoobj,inputframeno);
    inputframe = imresize(inputframe,inputresolution);
    inputframe = im2double(inputframe(inpbbox(i,2)+1:inpbbox(i,2)+inpbbox(i,4),...
                                      inpbbox(i,1)+1:inpbbox(i,1)+inpbbox(i,3),:));
    %inputframebsrgb = inputframe.*imagerep;
    % Instead of doing dot product with background subtraction, take the
    % raw image itself
    inputframebsrgb = inputframe;
    
    for j=1:size(testbbox,1)
        % Calculating bgsubtracted rbg image of test frame
        testframebs = permute(data(:,:,:,testframeno),[4 2 3 1]);
        testframebs = permute(testframebs,[3 2 1]);
        testframebs = double(testframebs(testbbox(j,2)+1:testbbox(j,2)+testbbox(j,4),...
                                         testbbox(j,1)+1:testbbox(j,1)+testbbox(j,3)));
        imagerep = repmat(testframebs,[1,1,3]);
        imname = sprintf('frame_%05d.png',testframeno);
        testframe = imread([framedir '/' imname]);
        %testframe = read(videoobj,testframeno);
        testframe = imresize(testframe,inputresolution);
        testframe = im2double(testframe(testbbox(j,2)+1:testbbox(j,2)+testbbox(j,4),...
                                        testbbox(j,1)+1:testbbox(j,1)+testbbox(j,3),:));
        %testframebsrgb = testframe.*imagerep;
        % Instead of doing dot product with background subtraction, take the
        % raw image itself
        testframebsrgb = testframe;
        
        % Getting imhistrgb for input patch
        binpr = imhist(inputframebsrgb(:,:,1));%/(inpbbox(3)*inpbbox(4));
        binpg = imhist(inputframebsrgb(:,:,2));%/(inpbbox(3)*inpbbox(4));
        binpb = imhist(inputframebsrgb(:,:,3));%/(inpbbox(3)*inpbbox(4));
        binp = [binpr,binpg,binpb];
        binp(1,:) = zeros(1,3);
        % Getting imhistrgb for test patch
        btestr = imhist(testframebsrgb(:,:,1));%/(testbbox(3)*testbbox(4));
        btestg = imhist(testframebsrgb(:,:,2));%/(testbbox(3)*testbbox(4));
        btestb = imhist(testframebsrgb(:,:,3));%/(testbbox(3)*testbbox(4));
        btest = [btestr,btestg,btestb];
        btest(1,:) = zeros(1,3);
        euclideanscore(i,j) = norm(binp-btest);
%         klscorer = 0;
%         klscoreg = 0;
%         klscoreb = 0;
               
%         for k=1:length(binpr)
%             if binpr(k)~=0 && btestr(k)~=0
%                 klscorer = klscorer+binpr(k)*log(binpr(k)/btestr(k));
%             end
%             if binpg(k)~=0 && btestg(k)~=0
%                 klscoreg = klscoreg+binpg(k)*log(binpg(k)/btestg(k));
%             end
%             if binpb(k)~=0 && btestb(k)~=0
%                 klscoreb = klscoreb+binpb(k)*log(binpb(k)/btestb(k));
%             end
%         end
%         klscore(i,j) = (klscorer+klscoreg+klscoreb)/3;
    end
end

if i==1 && j==1
    if euclideanscore<histscorethresh % & klscore<histscorethresh
        match = 1;
    else
        match =0;
    end
else
    match = zeros(min(size(inpbbox,1),size(testbbox,1)),1);
    for i=1:min(size(inpbbox,1),size(inpbbox,1));
        [sortedklscore,indc] = sort(euclideanscore);
        [~,indr] = sort(sortedklscore,2);
        match(indc(1,indr(1,1))) = indr(1,1);
        euclideanscore(indc(1,indr(1,1)),:) = Inf(1,size(euclideanscore,2));
        euclideanscore(:,indr(1,1)) = Inf(size(euclideanscore,1),1);
    end
    match = find(match);
end
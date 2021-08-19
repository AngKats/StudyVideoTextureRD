function features = ExtractSTFeat(videoName, width, height, nFrames, path)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: videoName (the name of the YUV video), width, height, nFrames (number of frames), path (of the YUV video)
% Outputs: features - 1x20 vector with all the features.
%
% Requires: loadFileYuv.m - or any other function that reads the YUV file and returns the Y components as a cell.
% Example of usage: features = ExtractSTFeat('Toddler-Fountain.yuv', 3840, 2160, 64, '/VideoData')
%
% Copyright (c) 2019-2020, Angeliki Katsenou, angeliki.katsenou@bristol.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

firstFrame = 1;
nFeatures = 20;
bitDepth = 10;

features=zeros(1,nFeatures);
stats_glcm=zeros(5,nFrames);
stCxy=zeros(5,nFrames);




disp('............................................................')
disp(['Feature Extraction from ' videoName '- is starting!!'])
disp('............................................................')

% Read the YUV file - save Y components of nFrames
[Y] = loadFileYuv([path '/' videoName], width, height, [1:nFrames], 0, bitDepth);



for i = firstFrame+1 : nFrames-1

        x = Y{1,i}(:,:,1);
        y = Y{1,i+1}(:,:,1);

     disp('............................................................')
     disp(['GLCM: frame ' int2str(i)])
     disp('............................................................')
    %% Compute the GLCM statistics
        [glcms] = graycomatrix(x,'GrayLimits',[0 2^(bitDepth-1)],'NumLevels',2^bitDepth);
        stats = graycoprops(glcms);
        stats_glcm(1,i)=stats.Contrast;
        stats_glcm(2,i)=stats.Correlation;
        stats_glcm(3,i)=stats.Energy;
        stats_glcm(4,i)=stats.Homogeneity;
        stats_glcm(5,i)=entropy(glcms);


     disp('............................................................')
     disp(['TC: frame ' int2str(i)])
     disp('............................................................')
    % Check temporal coherence among successive frames
        Cxy(:,i)=mscohere(double(x(:)),double(y(:)));
        stCxy(1,i)=mean2(Cxy);
        stCxy(2,i)=std2(Cxy);
        stCxy(3,i)=skewness(Cxy(:));
        stCxy(4,i)=kurtosis(Cxy(:));
        stCxy(5,i)=entropy(Cxy(:));
end

disp('............................................................')
disp('Compute Temporal Mean and Standard Deviation')
disp('............................................................')
	      features(1,1) = mean(stats_glcm(1,:));
        features(1,2) = mean(stats_glcm(2,:));
        features(1,3) = mean(stats_glcm(3,:));
        features(1,4) = mean(stats_glcm(4,:));
        features(1,5) = mean(stats_glcm(5,:));

        features(1,6) = std(stats_glcm(1,:));
        features(1,7) = std(stats_glcm(2,:));
        features(1,8) = std(stats_glcm(3,:));
        features(1,9) = std(stats_glcm(4,:));
        features(1,10) = std(stats_glcm(5,:));

	      features(1,11) = mean(stCxy(1,:));
        features(1,12) = mean(stCxy(2,:));
        features(1,13) = mean(stCxy(3,:));
        features(1,14) = mean(stCxy(4,:));
        features(1,15) = mean(stCxy(5,:));

        features(1,16) = std(stCxy(1,:));
        features(1,17) = std(stCxy(2,:));
        features(1,18) = std(stCxy(3,:));
        features(1,19) = std(stCxy(4,:));
        features(1,20) = std(stCxy(5,:));


%fileName=['resPath' videoName(1:end-4) '_' int2str(nFrames) 'frames.mat']
%save(fileName,'features');

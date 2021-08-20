ExtractSTFeat(videoName, width, height, nFrames, path)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: videoName (the name of the YUV video), width, height, nFrames (number of frames), path (of the YUV video)
% Outputs: features - 1xnFeatures vector with all the features.
%
% Requires: loadFileYuv.m - or any other function that reads the YUV file and returns the Y components as a cell.
% Example of usage: features = ExtractSTFeat('calmingwater.yuv', 256, 256, 100, '/VideoData')
%
% Copyright (c) 2017-2021, Angeliki Katsenou, angeliki.katsenou@bristol.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

firstFrame = 1;
nFeatures = 20;
bitDepth = 8;
wsize = 32 % size depends on the spatial resolution

features = zeros(1,nFeatures);
stats_glcm = zeros(5,nFrames);
stCxy = zeros(5,nFrames);
count = 0;


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
    % Compute the GLCM statistics
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


    disp('............................................................')
    disp(['NCC: frame ' int2str(i)])
    disp('............................................................')
    % check Normalized Cross-corelation among successive frames
        maxWinNCC = ComputeNCC(x, y, width, height, wsize);  
        meanNCC(1,i)=mean( maxWinNCC(:) );
        stdNCC(1,i)=std( maxWinNCC(:) );
        skNCC(1,i)=skewness( maxWinNCC(:) );
        kurtNCC(1,i)=kurtosis( maxWinNCC(:) );
        entrNCC(1,i)=entropy( maxWinNCC(:) );

    disp('............................................................')
    disp(['ALPD: frame ' int2str(i)])
    disp('............................................................')
    % Check the level of granularity
        ALPD(1,i) = ComputeALPD(x, width, height);

    disp('............................................................')
    disp(['OF: frame ' int2str(i)])
	disp('............................................................')
	% Extract the statistics from Optical Flow
	count = count+1;
	flow = estimateFlow(opticFlow,uint8(x));

	[curlOF,cavOF] = curl(flow.Vx,flow.Vy);
	meanCurlOF( 1,count ) = mean2(curlOF);
	stdCurlOF( 1, count ) = std2(curlOF);
	meanCavOF( 1, count ) = mean2(cavOF);
	stdCavOF( 1, count ) = std2(cavOF);


	meanCovVx( 1, count ) = mean2( cov(flow.Vx) );
	stdCovVx( 1, count ) = std2( cov(flow.Vx) );
	meanCovVy( 1,count ) = mean2( cov(flow.Vy) );
	stdCovVy( 1, count) = std2( cov(flow.Vy) );
	meanCovVxVy( 1, count ) = mean2( cov(flow.Vx,flow.Vy) );
	stdCovVxVy( 1, count ) = std2( cov(flow.Vx,flow.Vy) );

	%Extract the statistics from Magnitude and Orientation
	[No, edgeso] = histcounts( flow.Orientation(:) );
	[Nm, edgesm] = histcounts( flow.Magnitude(:) );

	tempMag = flow.Magnitude;
	hm = histogram( double( tempMag ) );
	HM{ 1, count } = hm.Values;
	meanHM( 1, count ) = mean2( tempMag );
	stdHM( 1, count ) = std2( tempMag );

	tempOr( :, :, count ) = flow.Orientation;
	ho = histogram( double( tempOr ) );
	HO{ 1, count } = ho.Values;
	meanHO( 1, count ) = mean2( tempOr );
	stdHO( 1, count ) = std2( tempOr );

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

        features(1,21) = mean(meanNCC);
        features(1,22) = mean(stdNCC);
        features(1,23) = mean(skNCC);
        features(1,24) = mean(kurtNCC);
        features(1,25) = mean(entrNCC);

        features(1,26) = mean(ALPD);
        features(1,27) = std(ALPD);

        features(1,28)=mean(meanHM(1,:));
        features(1,29)=mean(stdHM(1,:));
        features(1,30)=mean(meanHO(1,:));
        features(1,31)=mean(stdHO(1,:));
        features(1,32)=mean(meanCurlOF(1,:));
        features(1,33)=mean(stdCurlOF(1,:));
        features(1,34)=mean(meanCavOF(1,:));
        features(1,35)=mean(stdCavOF(1,:));
        features(1,40)=mean(meanCovVx(1,:));
        features(1,41)=mean(stdCovVx(1,:));
        features(1,42)=mean(meanCovVy(1,:));
        features(1,43)=mean(stdCovVy(1,:));
        features(1,44)=mean(meanCovVxVy(1,:));
        features(1,45)=mean(stdCovVxVy(1,:));




fileName=['resPath' videoName(1:end-4) '_' int2str(nFrames) 'frames.mat']
save(fileName,'features');

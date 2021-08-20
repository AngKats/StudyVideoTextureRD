function ALPD = ComputeALPD(frame, width, height)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function computes the distance of the peaks in the wavelet domain to assess texture granularity.
% Inputs: frame - usually the first frame
% Outputs: ALPD - a value indicative of the level of granularity.
%
% Requires: a Y frame (matrix heightxwidth) from a YUV video sequence.
% Example of usage: ALPD = ComputeALPD(Y, 256, 256);
%
% Copyright (c) 2019-2020, Angeliki Katsenou, angeliki.katsenou@bristol.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Computation of wavelet components
    [ca, chd, cvd, cdd] = swt2(x(:,:,1), 3, 'sym4'); %3 levels
    
    % Threshold for filtering outliers - defined experimentally
    thres = 10; 

    for j = 1:height
        [pks, locs] = findpeaks( double( chd( j, : ) ) );
        index = find( abs( pks)>thres );
        locs2 = locs( index );
        dist_locs_h( j ) = mean( [locs2 width] - [1 locs2] );
    end

    for k = 1:width
        [pks, locs] = findpeaks( double( cvd( :, k ) ) );
        index = find( abs( pks)>thres );
        locs2 = locs( index );
        dist_locs_v( k ) = mean( [locs2; height] - [1; locs2] );
    end

    ALPD = mean( dist_locs_v ) + mean( dist_locs_h );
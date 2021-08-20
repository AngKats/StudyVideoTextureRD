function maxWinNCC = ComputeNCC(frame1, frame2, width, height, wsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function computes the distance of the peaks in the wavelet domain to assess texture granularity.
% Inputs: frame1, frame2 - two successive frames
% Outputs: maxWinNCC - a matrix with the highest recorded NCC values
%
% Requires: two Y successive frames (matrix heightxwidth) from a YUV video sequence.
% Example of usage: ALPD = ComputeALPD(Y, 256, 256);
%
% Copyright (c) 2019-2020, Angeliki Katsenou, angeliki.katsenou@bristol.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        count1 = 0;

        for j = 1 : wsize : size( frame1, 1 ) - wsize 
            count1 = count1 + 1;

            count2 = 0;
            for jj = 1: wsize : size(frame1,1) - wsize 
                count2 = count2 + 1;
                winFrame1 = x( j : j + wsize -1, jj : jj + wsize - 1);

                cor = normxcorr2( winFrame1, frame2 );
                max_wnd( count1, count2 )=max( cor(:) );
                
            end 
        end    

maxWinNCC =  max_wnd;      
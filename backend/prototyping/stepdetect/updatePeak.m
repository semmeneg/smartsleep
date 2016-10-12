function [ recentPeaks, recentPeaksIdx, peakWindow ] = updatePeak( recentPeaks, recentPeaksIdx, n, np, BETA, M )
%UPDATEPEAK Summary of this function goes here
%   Detailed explanation goes here

    % NOTE: mu and sigma are calculated for recent M
    % peaks/valleys
    recentPeaks( recentPeaksIdx ) = n - np;
    recentPeaksIdx = recentPeaksIdx + 1;
    if ( recentPeaksIdx > M )
        recentPeaksIdx = 1;
    end

    muP = mean( recentPeaks );
    sigmaP = std( recentPeaks );
    peakWindow = muP + ( sigmaP / BETA );
end

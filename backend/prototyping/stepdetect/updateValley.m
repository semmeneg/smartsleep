function [ recentValleys, recentValleysIdx, valleyWindow ] = updateValley( recentValleys, recentValleysIdx, n, nv, BETA, M )
%UPDATEVALLEYS Summary of this function goes here
%   Detailed explanation goes here

    % NOTE: mu and sigma are calculated for recent M
    % peaks/valleys
    recentValleys( recentValleysIdx ) = n - nv;
    recentValleysIdx = recentValleysIdx + 1;
    if ( recentValleysIdx > M )
        recentValleysIdx = 1;
    end

    muV = mean( recentValleys );
    sigmaV = std( recentValleys );
    valleyWindow = muV + ( sigmaV / BETA );
end

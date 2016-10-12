function [ outliers ] = getOutliers( ts, stdFraction )
%GETOUTLIERS Summary of this function goes here
%   Detailed explanation goes here

    outliers = ts - mean( ts ) > stdFraction * std( ts );
end


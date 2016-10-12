function [ ] = showXCovPlots( dsout )
%SHOWXCOVPLOTS Summary of this function goes here
%   Detailed explanation goes here

    for i = 1 : 10
        createXCovFigure( dsout.Sensors, i, true );
    end
end


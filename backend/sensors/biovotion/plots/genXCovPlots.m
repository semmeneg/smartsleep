function [ ] = genXCovPlots( dsout, outputFilePath )
%PLOTCORR Summary of this function goes here
%   Detailed explanation goes here

    for i = 1 : 10
        f = createXCovFigure( dsout, i, false );

        if ( ~exist( outputFilePath, 'dir' ) )
            mkdir( outputFilePath );
        end

        outputFileName = sprintf( '%s\\%s.png', outputFilePath, dsout.Sensors.vnames{ :, i } );

        saveas( f, outputFileName, 'png' );
    end
end

function [ basisPeakData ] = processAndSaveBasisPeakJSONData( jsonFile, matOutputFile )
%PREPROCESSMETRICJSON Summary of this function goes here
%   Detailed explanation goes here

    basisPeakData = loadjson( jsonFile );
    
    for i = 1 : length( basisPeakData.metrics )
        channelNames = fieldnames( basisPeakData.metrics{ 1, i }.metrics ); 
       
        for j = 1 : numel( channelNames )
            metricValues = basisPeakData.metrics{ 1, i }.metrics.( channelNames{ j } ).values;
            values = zeros( 1, length( metricValues ) );

            for k = 1 : length( values )
                v = metricValues( k );

                if ( iscell( v ) )
                    v = cell2mat( v );

                    if ( isempty( v ) )
                        values( k ) = NaN;
                    else
                         values( k ) = v;
                    end
                else
                     values( k ) = v;
                end
            end

            basisPeakData.metrics{ 1, i }.metrics.( channelNames{ j } ).values = values;
        end
    end
    
    save( matOutputFile, 'basisPeakData' );
end


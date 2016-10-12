function [ symbolVector, symbols ] = RangesQuantizer( featureVector, ranges )
%RANGESQUANTIZER Summary of this function goes here
%   Detailed explanation goes here

    symbols = 1 : length( ranges );
    
    % if first value of feature-vector is NaN it will be set to nothing
    symbol = 1;
    symbolVector = zeros( 1, length( featureVector ) );
    
    for i = 1 : length( featureVector )
        scalar = featureVector( i );

        if ( isnan( scalar ) )
            %warning( 'Found NaN in feature-vector, will be replaced by nearest not NaN' );
        else
            for j = 1 : length( ranges )
                r = ranges{ j };

                if ( scalar > r( 1 ) && scalar <= r( 2 ) )
                    symbol = j;
                    break;
                end
            end
        end
        
        symbolVector( i ) = symbol;
    end
end


function [ symbolVector, symbols ] = StepsMeanQuantizer( featureVector )
%STEPSMEANQUANTIZER Summary of this function goes here
%   Detailed explanation goes here

    % SYMBOLS
    %   1:  'nothing'   (0,   2]
    %   2:  'low'       (2,   6]
    %   3:  'medium'    (6,  12]
    %   4:  'high'      (12, 20]
    symbols = [ 1 : 4 ];
    
    % if first value of feature-vector is NaN it will be set to nothing
    s = 1;
    symbolVector = zeros( 1, length( featureVector ) );
    
    for i = 1 : length( featureVector )
        scalar = featureVector( i );
        
        if ( isnan( scalar ) )
            % warning( 'Found NaN in feature-vector, will be replaced by nearest not NaN' );
        else
            if ( scalar <= 2 )
               s = 1;

            elseif ( scalar > 2 && scalar <= 6 )
                s = 2;

            elseif ( scalar > 6 && scalar <= 12 )
                s = 3;

            elseif ( scalar > 12 )
                s = 4;
            end
        end
        
        symbolVector( i ) = s;
    end
end


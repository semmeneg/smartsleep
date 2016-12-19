function [ symbolVector, symbols ] = HRMeanQuantizer( featureVector )
%HRME Summary of this function goes here
%   Detailed explanation goes here

    % SYMBOLS
    %   1:  'low'           (0,   55]
    %   2:  'normal'        (55,  80]
    %   3:  'excited'       (80, 100]
    %   4:  'high'          (100, 130]
    %   5:  'very high'     (130, 170]
    %   6:  'extreme'       (170, 250]
    symbols = [ 1 : 6 ];
    
    % if first value of feature-vector is NaN it will be set to normal
    s = 2;
    symbolVector = zeros( 1, length( featureVector ) );
    
    for i = 1 : length( featureVector )
        scalar = featureVector( i );
        
        if ( isnan( scalar ) )
            % warning( 'Found NaN in feature-vector, will be replaced by nearest not NaN' );
        else
            if ( scalar <= 55 )
               s = 1;

            elseif ( scalar > 55 && scalar <= 80 )
                s = 2;

            elseif ( scalar > 80 && scalar <= 100 )
                s = 3;

            elseif ( scalar > 100 && scalar <= 130 )
                s = 4;

            elseif ( scalar > 130 && scalar <= 170 )
                s = 5;

            elseif ( scalar > 170 )
                s = 6;
            end
        end
        
        symbolVector( i ) = s;
    end
end
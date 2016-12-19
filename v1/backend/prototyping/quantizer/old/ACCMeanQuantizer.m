function [ symbolVector, symbols ] = ACCMeanQuantizer( featureVector )
%ACCMEANQUANTIZER Summary of this function goes here
%   Detailed explanation goes here

    % SYMBOLS
    %   1:  'very high neg' (-inf, -3]
    %   2:  'high neg'      (-3, -2]
    %   3:  'medium neg'    (-2,  -1]
    %   4:  'normal neg'    (-1,  -0.1]
    %   5:  'zero'          (-0.1, +0.1]
    %   6:  'normal pos'    (0.1, 1.0]
    %   7:  'medium pos'    (1, 2]
    %   8:  'high pos'      (2, 3]
    %   9:  'very high pos' (3, +inf]
    
    symbols = [ 1 : 9 ];
    
    % if first value of feature-vector is NaN it will be set to nothing
    symbol = 5;
    symbolVector = zeros( 1, length( featureVector ) );
    
    for i = 1 : length( featureVector )
        scalar = featureVector( i );

        if ( isnan( scalar ) )
            %warning( 'Found NaN in feature-vector, will be replaced by nearest not NaN' );
        else
            if ( scalar <= -3 )
               symbol = 1;

            elseif ( scalar > -3 && scalar <= -2 )
                symbol = 2;

            elseif ( scalar > -2 && scalar <= -1 )
                symbol = 3;

            elseif ( scalar > -1 && scalar <= -0.1 )
                symbol = 4;
                
            elseif ( scalar > -0.1 && scalar < 0.1 )
                symbol = 5;
                
            elseif ( scalar >= 0.1 && scalar < 1.0 )
                symbol = 6;
            
            elseif ( scalar >= 1.0 && scalar < 2.0 )
                symbol = 7;
            
            elseif ( scalar >= 2.0 && scalar < 3.0 )
                symbol = 8;
            
            elseif ( scalar >= 3.0 )
                symbol = 9;
             
            end
        end
        
        symbolVector( i ) = symbol;
    end
end


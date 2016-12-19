function [ quantizedFeatures, quantizationSymbols ] = Quantize( featureVector, componentInfo, componentQuantizingInfo )
%QUANTIZE Summary of this function goes here
%   Detailed explanation goes here

    featureLength = length( featureVector );

    components = unique( componentInfo );

    for i = 1 : length( components )
        c = components( i );
        idx = find( componentInfo == c );
        
        if ( false == iscell( componentQuantizingInfo{ i } ) )
            if ( isnan( componentQuantizingInfo{ i } ) )
                quantizationSymbols( i ) = NaN;
                continue;
            end
        end
        
        dimensions = length( idx );
        isScalar = dimensions == 1;
        vec = zeros( dimensions, featureLength );
        
        for j = 1 : dimensions
            vec( j, : ) = removeNan( featureVector( idx( j ), : ) );
%             bd=isnan( vec( j, : ) );
%             gd=find(~bd);
% 
%             bd([1:(min(gd)-1) (max(gd)+1):end])=0;
%             vec( j, bd )=interp1(gd,vec(j,gd),find(bd));
        end

        if ( isScalar )
            [ symbolVector, symbols ] = RangeQuantizer( ...
                vec, componentQuantizingInfo{ i } );
            quantizationSymbols( i ) = length( symbols );
            
        else
            symbolVector = kmeans( vec', componentQuantizingInfo{ i } );
            quantizationSymbols( i ) = componentQuantizingInfo{ i };
        end
        
        quantizedFeatures( i, : ) = symbolVector;
    end    
end

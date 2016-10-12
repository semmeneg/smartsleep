function [ reducedVec ] = pcaReduce( dataVec, reductionMat )
%PCAREDUCE Summary of this function goes here
%   Detailed explanation goes here

    [ rows, cols ] = size( reductionMat );
    
    reducedVec = zeros( cols, length( dataVec ) );
    
    for i = 1 : length( dataVec )
        x = dataVec( i, : );
        y = reductionMat' * x';
        
        reducedVec( :, i ) = y;
    end
    
    for i = 1 : cols
        reducedVec( i, : ) = removeNan( reducedVec( i, : ) );
    end
end

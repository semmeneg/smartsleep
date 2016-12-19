function [ reductionMat ] = pcaReductionMat( dataVec, VAR_LIMIT, MIN_DIMENSIONS )
%PCAREDUCTIONMAT Summary of this function goes here
%   Detailed explanation goes here

    [ coeff, score, latent, tsquared, explained, mu ] = pca( dataVec );
   
    % explained holds the relative variance of the coefficient-vectors
    
    % sum up until >= varLimit BUT take at least MIN_DIMENSIONS dimensions (if present)
    s = 0.0;
    coeffIndex = 0;
    
    for i = 1 : length( explained );
        s = s + explained( i );
        
        if ( s >= VAR_LIMIT )
            if ( length( explained ) >= MIN_DIMENSIONS && i < MIN_DIMENSIONS )
                continue
            end
            
            coeffIndex = i;
            break;
        end
    end
    
    reductionMat = coeff( : , 1 : coeffIndex );
end

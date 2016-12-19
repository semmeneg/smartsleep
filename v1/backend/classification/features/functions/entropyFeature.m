function [ scalar ] = entropyFeature( data, featureInfo )
%ENTROPYFEATURE Summary of this function goes here
%   Detailed explanation goes here

       % !!!!!! Requires Matlab Image Processing Toolkit. 
        scalar = entropy( data{ 1 } );
        
        % Alternative function ???
%         scalar =  -sum(data{ 1 }.*log2(data{ 1 }));
end


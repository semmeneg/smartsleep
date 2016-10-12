function [ symbolVector, symbols ] = VectorQuantizer( featureVector )
%VECTORQUANTIZER Summary of this function goes here
%   Detailed explanation goes here

    symbols = 1 : 10;
    symbolVector = kmeans( featureVector', 10 );
end


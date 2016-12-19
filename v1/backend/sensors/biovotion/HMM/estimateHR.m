function [ TRANS, EMIS ] = estimateHR( dsout, windowWidth )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    seq = calculateSEQ_FFT( dsout, windowWidth );
    
    [ TRANS, EMIS ] = hmmestimate( seq, dsout.Labels.Index );
end

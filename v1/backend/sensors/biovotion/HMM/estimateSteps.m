function [ TRANS, EMIS ] = estimateSteps( dsout, windowWidth )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    seq = calculateSEQ_Steps( dsout, windowWidth );
    
    [ TRANS, EMIS ] = hmmestimate( seq, dsout.Labels.Index );
end

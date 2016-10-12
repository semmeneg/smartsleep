function [ prob ] = visibleProbRBM( RBM, hiddenProb )
%VISIBLEPROBRBM Summary of this function goes here
%   Detailed explanation goes here

    prob = 1./(1 + exp( -hiddenProb * RBM.W' - RBM.a ) );  
end


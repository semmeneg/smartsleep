function varargout = mybalance(varargin)
% SYNTAX: varargout = mybalance(varargin)
% [out1 out2 ... outn] = mybalance(in1, in2, ... inn). OUT1-OUTN will
% have the same number of rows as the minimum number of rows of IN1-INN. 
%
% INPUTS: 
%       varargout - 
%
% OUTPUT: 
%       varargout - 
%
% EXAMPLE: 
% 
% a1 =
% 
%      1
%      2
%      3
% 
% 
% b1 =
% 
%      4
%      5
%      
% [a2 b2] = mybalance(a1, b1)
% 
% a2 =
% 
%      1
%      2
% 
% 
% b2 =
% 
%      4
%      5
%
% Created by Martin Längkvist, 2012

if unique(cellfun('length',varargin))>0
    n = min(cellfun('length',varargin));
    for i=1:nargin
        varargout{i} = varargin{i}(1:n,:);
    end

end
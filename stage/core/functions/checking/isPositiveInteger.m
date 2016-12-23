function [ out ] = isPositiveInteger( value )
out = (isnumeric(value)) && (round(value) == value);
end


function [ flag ] = matchStringCells( cell1, cell2 )
%MATCHSTRINGCELLS Summary of this function goes here
%   Detailed explanation goes here

    flag = false;
    
    cellLength = length( cell1 );
    
    % selected signals must match
    if ( cellLength ~= length( cell2 ) )
        return;
    end
    
    % selected signals must match
    for i = 1 : cellLength
        if ( false == strcmpi( cell1{ i }, cell2{ i } ) )
            return;
        end
    end
    
    flag = true;
end

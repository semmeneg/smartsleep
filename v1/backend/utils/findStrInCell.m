function [ idx ] = findStrInCell( cell, str )
%FINDCELLIDX Summary of this function goes here
%   Detailed explanation goes here

    allIdx = strfind( cell, str );
    idx = find( not( cellfun( 'isempty', allIdx ) ) );
    
    if ( length( idx ) > 1 )
        for i = idx
            if ( strcmp( cell{ i }, str ) )
                idx = i;
                break;
            end
        end
    end
end

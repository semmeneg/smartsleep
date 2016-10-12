function [ ] = genEdgeDetectFigures( dsout, i, outputFilePath )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if ( ~exist( outputFilePath, 'dir' ) )
        mkdir( outputFilePath );
    end
        
    fileName = sprintf( '%s\\Med1_ThreshFree', outputFilePath );
    f = createEdgeDetectFigure( dsout, i, 1, [] );
    saveas( f, fileName, 'fig' );
    set( f, 'visible', 'off' );
    
    fileName = sprintf( '%s\\Med5_ThreshFree', outputFilePath );
    f = createEdgeDetectFigure( dsout, i, 5, [] );
    saveas( f, fileName, 'fig' );
    set( f, 'visible', 'off' );
    
    fileName = sprintf( '%s\\Med10_ThreshFree', outputFilePath );
    f = createEdgeDetectFigure( dsout, i, 10, [] );
    saveas( f, fileName, 'fig' );
    set( f, 'visible', 'off' );
    
    
    fileName = sprintf( '%s\\Med1_Thresh01', outputFilePath );
    f = createEdgeDetectFigure( dsout, i, 1, 0.1 );
    saveas( f, fileName, 'fig' );
    set( f, 'visible', 'off' );
    
    fileName = sprintf( '%s\\Med5_Thresh01', outputFilePath );
    f = createEdgeDetectFigure( dsout, i, 5, 0.1 );
    saveas( f, fileName, 'fig' );
    set( f, 'visible', 'off' );
    
    fileName = sprintf( '%s\\Med10_Thresh01', outputFilePath );
    f = createEdgeDetectFigure( dsout, i, 10, 0.1 );
    saveas( f, fileName, 'fig' );
    set( f, 'visible', 'off' );
end


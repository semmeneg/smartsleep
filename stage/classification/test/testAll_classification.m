function [result] = testAll_classification( )
    folder = strrep(mfilename('fullpath'), mfilename() , ''); % gets current folder
    folderSuite  = matlab.unittest.TestSuite.fromFolder(folder);
    if(isempty(folderSuite))
        error('No test found or test code has errors in %s .', folder);
    end
    folderSuite.run();
end


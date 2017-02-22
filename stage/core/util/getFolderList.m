% Returns a distinct list of folders matching the patterns
%
function [ foldersList ] = getFolderList( folderPatterns )
    
    if(ischar(folderPatterns))
        folderPatterns = {folderPatterns};
    end

    foldersList = [];
    for folderPattern = folderPatterns
        folders = dir( cell2mat(folderPattern) );
        foldersList = [foldersList ; folders( [ folders.isdir ] )];
    end
    
    [~,ii]=unique({foldersList.name},'stable');
    foldersList=foldersList(ii);

end


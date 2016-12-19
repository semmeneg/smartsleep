userId = 'jonathan.thaler@fhv.at';      %'ureimer@me.com'
password = 'jonathan1';                 %jonathan1
dateFrom = '2015-09-28';
dateTo = '2015-10-09';

basisPeakData = loadAllUserData( userId, password, dateFrom, dateTo );
fileName =  sprintf( 'D:\\Dropbox\\Dropbox\\FH\\Job\\SmartSleep FH\\Data\\BasisPeak\\%s_%s_%s_%s', ...
    userData.userDetails.profile.first_name, ...
    userData.userDetails.profile.last_name, ...
    dateFrom, dateTo );

save( fileName, 'basisPeakData' );
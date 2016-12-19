function E = sect2E(sect, width, ss)
% sect2E Creates a feature extraction matrix from a sector with window width
% WIDTH and step size SS. SECT is a nxm matrix with n samples and m channels
%
% Each row in E corresponds to one window and each column is one feature.
%
% Created by Martin Längkvist, 2012

HDR = evalin('base','HDR');

nt = floor((size(sect,1) - width) / ss) + 1;

E=zeros(nt,28);

% hwaitbar = waitbar(0.0,'Loading sect2E','CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
% setappdata(hwaitbar,'canceling',0)
% set(hwaitbar,'Name','Initializing...');

for i=1:nt
    b = sect((1+ss*(i-1)):(width+ss*(i-1)),:);
    
%     waitbar(i/nt, hwaitbar);
%     if getappdata(hwaitbar,'canceling')
%         break
%     end
    
    E(i,:)=[seg2E(b(:,HDR.EEG(1)), width, ss, 'fft') ...    % 1 - 5
        seg2E(b(:,HDR.EOG(1)), width, ss, 'fft') ...        % 6 - 10
        seg2E(b(:,HDR.EMG(1)), width, ss, 'fft') ...        % 11 - 15
        seg2E(b(:,HDR.EMG(1)), width, ss, 'median') ...     % 16
        seg2E(b(:,HDR.EOG), width, ss, 'eyecorr') ...       % 17
        seg2E(b(:,HDR.EEG(1)), width, ss, 'kurtosis') ...   % 18
        seg2E(b(:,HDR.EOG(1)), width, ss, 'kurtosis') ...   % 19
        seg2E(b(:,HDR.EMG(1)), width, ss, 'kurtosis') ...   % 20
        seg2E(b(:,HDR.EOG(1)), width, ss, 'std') ...        % 21
        seg2E(b(:,HDR.EEG(1)), width, ss, 'entropy') ...    % 22
        seg2E(b(:,HDR.EOG(1)), width, ss, 'entropy') ...    % 23
        seg2E(b(:,HDR.EMG(1)), width, ss, 'entropy') ...    % 24
        seg2E(b(:,HDR.EEG(1)), width, ss, 'smean') ...      % 25
        seg2E(b(:,HDR.EOG(1)), width, ss, 'smean') ...      % 26
        seg2E(b(:,HDR.EMG(1)), width, ss, 'smean') ...      % 27
        seg2E(b(:,HDR.EEG(1)), width, ss, 'fractalexp')];   % 28
    
end

% if exist('hwaitbar')
%     delete(hwaitbar);
% end

end


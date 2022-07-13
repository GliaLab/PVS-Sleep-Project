function TeamViewerQS(forceUpdate,ageLimit)
    if nargin < 1 || isempty(forceUpdate)
        forceUpdate = false;
    end
    
    if nargin < 2 || isempty(ageLimit)
        ageLimit = years(0.5);
    end
    
    try
        validateattributes(forceUpdate,{'numeric','logical'},{'scalar','binary'});
        validateattributes(ageLimit,{'duration'},{'scalar'});
        
        filename = fullfile(tempdir(),'TeamViewerQS.exe');
        
        if ~exist(filename,'file') || forceUpdate
            downloadTeamViewerQS(filename);
        else
            checkUpdate(filename,ageLimit);
        end
        
        f = waitbar(0.25,'Opening TeamViewer Quick Support');

        try
            status = system(filename);
            assert(status == 0,'Could not start TeamViewerQS');
        catch ME
            delete(f);
            rethrow(ME);
        end
        
        waitbar(1,f);
        delete(f);
        
    catch ME
        msgbox({'Could not start remote session.','Check internet connection.'}, 'Error','error');
        rethrow(ME);
    end
end

function checkUpdate(filename,ageLimit)
    try
        s = dir(filename);
        date = s.date;
        date = datetime(date,'InputFormat','dd-MMM-yyyy HH:mm:ss');
        now = datetime('now');
        age = now-date;

        if age > ageLimit
            downloadTeamViewerQS(filename);
        end
    catch
        fprintf(2,'Could not update TeamViewerQS to latest version.\n');
    end
end

function filename = downloadTeamViewerQS(filename)
    url = 'https://download.teamviewer.com/download/TeamViewerQS.exe';
    
    f = waitbar(0.25,'Downloading TeamViewer Quick Support');
    
    try
        filename = websave(filename,url,weboptions('ContentType','binary'));
    catch ME
        delete(f);    
        rethrow(ME);
    end
    
    waitbar(1,f);    
    delete(f);
    
    
end

%--------------------------------------------------------------------------%
% TeamViewerQS.m                                                           %
% Copyright © 2020 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2020 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%

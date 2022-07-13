function commitHash = getCommitHash()
    commitHash = '';
    
    try
        commithashPath = fullfile(scanimage.util.siRootDir(),'+scanimage','private','REF');
        
        if exist(commithashPath,'file')
            fid = fopen(commithashPath);
            try
                commitHash = fgetl(fid);
                fclose(fid);
            catch ME
                fclose(fid);
                rethrow(ME);
            end
        else
            commitHash = most.util.getGitCommitHash(scanimage.util.siRootDir());
        end
    catch
        % this function should never throw!
    end
end

%--------------------------------------------------------------------------%
% getCommitHash.m                                                          %
% Copyright © 2020 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2020 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%

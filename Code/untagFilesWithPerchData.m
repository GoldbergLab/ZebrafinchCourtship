function untagFilesWithPerchData(rootDataDirectory, otherDataExtension, dryRun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% untagFilesWithPerchData: Remove active perche tag from filenames
% usage:  untagFilesWithPerchData(rootDataDirectory, otherDataExtension, 
%   dryRun)
%
% where,
%    rootDataDirectory is a char array representing the root directory 
%       where all the tagged data files
%    otherDataExtension is a file extension that specifies what types of 
%       data files to look for
%    dryRun is a boolean flag indicating if the files should actually be
%       renamed or not.
%
% For the Zebrafinch Courtship project, take .nc files containing all perch
%   data together, and tag other data files based on which perches are
%   active. Also adds a "+" if two perches in the same box are both active
%   in the same file. This function removes those tags if necessary.
%
% See also: tagFilesWithPerchData
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('dryRun', 'var') || isempty(dryRun)
    dryRun = true;
end

% Remove period in extension if it exists
otherDataExtension = regexprep(otherDataExtension, '\.', '');

% Find file list
otherDataFiles = findFilesByRegex(rootDataDirectory, ['.*\.', otherDataExtension], false, false);

% Get # of matching files
nFiles = length(otherDataFiles);

% Note "_F\." is to fix a specific incorrect tag
tagFindPattern = '(\_[0-9]+[MF](\-[0-9]+F\+?)?)|(_F\.)';
tagReplacePattern = '(\_[0-9]+[MF](\-[0-9]+F\+?)?)|(_F)';

% Loop over file lists
for fileNum = 1:nFiles
    otherDataFile = otherDataFiles{fileNum};
    % Check if other data file has already been tagged
    if regexp(otherDataFile, tagFindPattern)
        newotherDataFile = regexprep(otherDataFile, tagReplacePattern, '');
        if dryRun
            fprintf('This would have moved:\n\t%s\nto\n\t%s\n\n', otherDataFile, newotherDataFile);
        else
            movefile(otherDataFile, newotherDataFile);
        end
    end
end
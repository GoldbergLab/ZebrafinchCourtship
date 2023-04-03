function tagFilesWithPerchData(rootPerchDirectory, rootDataDirectory, digitalConfigFilePath, otherDataExtension, dryRun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tagFilesWithPerchData: Tag data files based on active perches active 
% usage:  tagFilesWithPerchData(rootPerchDirectory, rootDataDirectory, 
%   digitalConfigFilePath, otherDataExtension, dryRun)
%
% where,
%    rootPerchDirectory is a char array representing the root directory 
%       where all the perch data is stored
%    rootDataDirectory is a char array representing the root directory 
%       where all the other data is stored
%    digitalConfigFilePath is the path to a digital configuration file
%    otherDataExtension is a file extension that
%       specifies what types of data files to look for
%    dryRun is a boolean flag indicating if the files should actually be
%       renamed or not.
%
% For the Zebrafinch Courtship project, take .nc files containing all perch
%   data together, and tag other data files based on which perches are
%   active. Also adds a "+" if two perches in the same box are both active
%   in the same file.
%
% See also: untagFilesWithPerchData
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('dryRun', 'var') || isempty(dryRun)
    dryRun = true;
end

% Read digital config file
digitalConfig = readtable(digitalConfigFilePath);
lineNumbers = digitalConfig.DigitalChannel;
shortNames = digitalConfig.ShortName;
boxNums = arrayfun(@num2str, digitalConfig.BoxNum, 'UniformOutput', false);

% Extension to use to look for perch data
perchDataExtension = 'nc';

% Remove period in extension if it exists
otherDataExtension = regexprep(otherDataExtension, '\.', '');

% Find file lists
otherDataFiles = findFilesByRegex(rootDataDirectory, ['.*\.', otherDataExtension], false, false);
perchFiles = findFilesByRegex(rootPerchDirectory, ['.*\.', perchDataExtension], false, false);

% Sanity check file lists
if length(otherDataFiles) ~= length(perchFiles)
    warning('Check files - different # of otherData and perch files');
end

% Get # of matching files
nFiles = min(length(otherDataFiles), length(perchFiles));

% Loop over file lists
for fileNum = 1:nFiles
    otherDataFile = otherDataFiles{fileNum};
    % Check if other data file has already been tagged
    if regexp(otherDataFile, '.*[0-9]+[MF](\-[0-9]+F\+?)?')
        warning('Found a file that was already tagged: %s', otherDataFile);
        continue;
    end

    perchFile = perchFiles{fileNum};
    otherDataFileNum = getFileNumber(otherDataFile);
    perchFileNum = getFileNumber(perchFile);
    % Check that file numbers match for corresponding files
    if otherDataFileNum ~= perchFileNum
        error('File numbers don''t match:\n %s\n vs\n %s', otherDataFile, perchFile);
    end
    
    % Load aggregate perch data
    data = egl_Intan_Nc(perchFile, true);

    % Extract individual boolean perch data for each perch
    perchesActive = false(1, length(lineNumbers));
    for k = 1:length(lineNumbers)
        lineNum = lineNumbers(k);
        binaryData = bitget(data, lineNum+1);
        if any(binaryData)
            perchesActive(k) = true;
        end
    end

    % Construct tag based on perch active data
    activeShortNames = shortNames(perchesActive);
    activeBoxNums = boxNums(perchesActive);

    isFemale = regexpmatch(activeShortNames, 'F');
    isMale = regexpmatch(activeShortNames, 'M');

    femaleTagPart = join(activeBoxNums(isFemale), '');
    if isempty(femaleTagPart)
        femaleTagPart = {''};
    end
    femaleTagPart = [femaleTagPart{1}, 'F'];
    maleTagPart = join(activeBoxNums(isMale), '');
    if isempty(maleTagPart)
        maleTagPart = {''};
    end
    maleTagPart = [maleTagPart{1}, 'M'];

    perchMatch = false;
    for boxIdx = 1:length(activeBoxNums)
        boxNum = activeBoxNums{boxIdx};
        if sum(strcmp(boxNum, activeBoxNums)) > 1
            perchMatch = true;
        end
    end

    if sum(isMale) > 0 && sum(isFemale) > 0
        tag = ['_', maleTagPart, '-', femaleTagPart];
    elseif sum(isMale)
        tag = ['_', maleTagPart];
    else
        tag = ['_', femaleTagPart];
    end

    if perchMatch
        tag = [tag, '+'];
    end

    [otherDataPath, otherDataName, otherDataExt] = fileparts(otherDataFile);
    newotherDataFile = fullfile(otherDataPath, [otherDataName, tag, otherDataExt]);

    if dryRun
        fprintf('This would have moved:\n\t%s\nto\n\t%s\n\n', otherDataFile, newotherDataFile);
    else
        movefile(otherDataFile, newotherDataFile);
    end
end

function fileNum = getFileNumber(file)
% Extract the numerical file number from a file name.
% Tags are separated by underscores, and there should only be one
% tag that is simply a number.

[~, name, ~] = fileparts(file);
tags = split(name, '_');
for tagNum = length(tags):-1:1
    % Starting with the last tag, check each one to see if it's a number
    tag = tags{tagNum};
    fileNum = str2double(tag);
    if isnumeric(fileNum) && ~isnan(fileNum)
        % This is probably the file number tag
        return
    end
end
error('Could not find file num amongst tags in %s', file);

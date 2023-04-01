function makeActiveAudioChannelAnnotations(rootDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% makeActiveAudioChannelAnnotations: Create active audio channel annotation
%   across a whole directory
% usage:  makeActiveAudioChannelAnnotations(rootDir)
%
% where,
%    rootDir is the root directory to look for audio files in
%
% This function is designed to take multichannel audio files generated by
%   the zebrafinch courtship project, and for each one, output an
%   annotation file which designates which audio channel appears to be the
%   active one at each point in time. See makeActiveAudioChannelAnnotation
%   for a more detailed description.
%
% See also: makeActiveAudioChannelAnnotation
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find all .wav files in the provided root directory
audioFiles = findFilesByRegex(rootDir, '.*\.wav', false, false);

succeedCount = 0;
failList = {};

fprintf('Making active audio channel annotations...\n');

% Loop over the found files
for k = 1:length(audioFiles)
    audioFile = audioFiles{k};

    % Display progress so the user knows it's still working
    displayProgress('Completed %d of %d.\n', k, length(audioFiles), 20);

    % Construct an output filename
    [audioDir, audioName, ~] = fileparts(audioFile);
    outputFile = fullfile(audioDir, [audioName, '_activeAudio', '.nc']);

    try
        % Create the annotation
        makeActiveAudioChannelAnnotation(audioFile, outputFile);
        succeedCount = succeedCount + 1;
    catch ME
        getReport(ME)
        failList{end+1} = audioFile;
    end
end

% Print a report
fprintf('Done making active audio channel annotations:\n')
fprintf('   Completed: %d\n', succeedCount);
fprintf('   Failed:    %d\n', length(failList));
for k = 1:length(failList)
    failFile = failList{k};
    fprintf('       %s\n', failFile);
end
fprintf('   Total:     %d\n', length(audioFiles));
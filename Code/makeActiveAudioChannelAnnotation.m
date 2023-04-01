function audioChannelAnnotation = makeActiveAudioChannelAnnotation(inputAudioFile, outputAnnotationFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% makeActiveAudioChannelAnnotation: Create active audio channel annotation
% usage:  audioChannelAnnotation = inputAudioFile(inputAudioFile)
%         audioChannelAnnotation = inputAudioFile(inputAudioFile, 
%           outputAudioFile)
%
% where,
%    inputAudioFile is a char array representing the path to a multichannel
%       audio .wav file to be analyzed
%    outputAnnotationFile is an optional char array representing the path 
%       where the output annotation file should be saved. If omitted or 
%       empty, it will not be saved, and the data will only be returned by 
%       the function as an array.
%    audioChannelAnnotation is a 1xN array of integers from 0 to C, where C
%       is the number of channels in the inputAudioFile, and N is the
%       number of samples in the audio file. Each element in this array
%       represents the channel number that appears to be active at that
%       moment. If no channels seem to be active, the array will contain
%       NaN for that sample.
%
% The zebrafinch courtship project generates multichannel audio files from
%   an arena with 12 microphones. There is some acoustic insulation between
%   the microphones, so it is possible to determine at each point in time
%   which microphone is recording the loudest sound. This should indicate
%   which microphone is actually next to the bird that is producing the
%   sound.
%
% See also: 
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('outputAnnotationFile', 'var') || isempty(outputAnnotationFile)
    outputAnnotationFile = [];
end

% Load audio data from wav file, along with the sampling rate Fs
[audioData, Fs] = audioread(inputAudioFile);
audioChannelAnnotation = findActiveAudioChannelAnnotation(audioData);

% If requested by the user, write the audio file as a .nc file
if ~isempty(outputAnnotationFile)
    try
        timeVector = getTimeVectorFromTimestampString(inputAudioFile);
    catch
        warning('Could not find a valid timestamp in the input filename. Output files will not have a valid time vector in their metadata.')
        timeVector = [0, 0, 0, 0, 0, 0, 0];
    end

    writeIntanNcFile(outputAnnotationFile, timeVector, 1/Fs, 0, ...
        'Active audio channel annotation', audioChannelAnnotation)
end

function audioChannelAnnotation = findActiveAudioChannelAnnotation(audioData)
% audioData is an N x C array, where N is the # of samples in the audio
% file, and C is the # of channels.

% This is where the magic happens!

audioChannelAnnotation = zeros(size(audioData, 1), 1);
function timeVector = getTimeVectorFromTimestampString(timestampString)
% Parse a filename in the format the PyVAQ outputs, look for a timestamp
%   string, and parse it into a time vector of the form 
%   [Y, M, D, H, M, S, uS]

% Search the timestampString for a date in the format YYYY-MM-DD-HH-MM-SS-uSSSSS
matches = regexp(timestampString, '([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{6})', 'tokens');

if isempty(matches) || length(matches{1}) ~= 7
    error('No valid timestamp found in ''%s''. Timestamp should be of the form YYYY-MM-DD-HH-MM-SS-uSSSSS.', timestampString);
end

% Convert the matched strings to a time vector
timeVector = cellfun(@(x)str2double(x), matches{1});
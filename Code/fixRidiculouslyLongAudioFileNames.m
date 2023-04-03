function fixRidiculouslyLongAudioFileNames(rootDirectory, dryRun)

if ~exist('dryRun', 'var') || isempty(dryRun)
    dryRun = true;
end

ridiculousFiles = findFilesByRegex(rootDirectory, ['(dev[0-9]+ai[0-9]+)+.*\.', 'wav'], false, true);

filesMoved = 0;

for k = 1:length(ridiculousFiles)
    ridiculousFile = ridiculousFiles{k};
    betterFile = regexprep(ridiculousFile, '(dev[0-9]+ai[0-9]+)+', 'multiAI');
    if dryRun
        fprintf('This would have moved:\n\t%s\n to \n\t%s\n\n', ridiculousFile, betterFile);
    else
        movefile(ridiculousFile, betterFile);
    end
    filesMoved = filesMoved + 1;
end

if filesMoved > 0
    if dryRun
        fprintf('Would have fixed %d ridiculously long filenames.\n', filesMoved);
    else
        fprintf('Fixed %d ridiculously long filenames.\n', filesMoved);
    end
else
    fprintf('No ridiculously long filenames found.\n');
end
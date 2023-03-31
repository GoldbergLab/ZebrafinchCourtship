function fixRidiculouslyLongAudioFileNames(rootDirectory, dryRun)

if ~exist('dryRun', 'var') || isempty(dryRun)
    dryRun = true;
end

ridiculousFiles = findFilesByRegex(rootDirectory, ['.*\.', 'wav'], false, false);

for k = 1:length(ridiculousFiles)
    ridiculousFile = ridiculousFiles{k};
    betterFile = regexprep(ridiculousFile, '(dev[0-9]+ai[0-9]+)+', 'multiAI');
    if dryRun
        fprintf('This would have moved:\n\t%s\n to \n\t%s\n\n', ridiculousFile, betterFile);
    else
        movefile(ridiculousFile, betterFile);
    end
end


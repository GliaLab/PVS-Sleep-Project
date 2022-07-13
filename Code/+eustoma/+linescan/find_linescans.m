function scans = find_linescans(path,engine)
paths = dir(fullfile(path,'**/*.meta.txt'));

if isempty(paths)
    begonia.logging.log(1,'No LineScans found')
    scans = [];
    return;
end

begonia.logging.log(1,'Finding LineScans')
paths = arrayfun(@(x){fullfile(x.folder,x.name)},paths);
% Some scans seems to start with ._, these are unusable and probably a
% backup thing from something.
paths = paths(~contains(paths,"._"));

for i = 1:length(paths)
    scans(i) = eustoma.linescan.LineScan(paths{i},engine);
end

begonia.logging.log(1,'%d LineScans found',length(scans));

end


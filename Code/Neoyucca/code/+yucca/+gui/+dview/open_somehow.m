function open_somehow(thing)

    % it's a bird, it's a plane, it's a...
    if isstruct(thing)
        thing
        return;
    end

    if isa(thing, 'rig.sup.DataLocation')
        rig.gui.DataViewer(thing, [], {'Name', 'Path'});
        return;
    end
    
    % dir's open externally
    try
        if exist(thing, 'dir') || exist(thing, 'file')
            open_external(thing);
            return;
        end
    catch
        
    end

    % everything else we just dump:
    thing

end


function open_external(path)

    if isunix
        cmd = ['xdg-open "' path '" &'];
        disp(['Opening external, linux style (fails - cut''n paste to console): ' newline cmd]);
        unix(cmd);
    elseif ispc
        disp(['Opening external, Windows style: winopen("' path '")']);
        winopen(path);
    elseif ismac
        cmd = ['open "' path '" &'];
        disp(['Opening external, macOS style: ' cmd]);
        system(cmd);
    end
end

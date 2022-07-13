function parallel_run(trials)
workers = 3;

tic
parfor (i = 1:length(trials),workers)
    dogbane.processing.aqua.run(trials(i));
end
toc

end


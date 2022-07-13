function state_histogram(tbl_episodes,state)


tbl_episodes = tbl_episodes(tbl_episodes.State == state,:);

figure;
histogram(tbl_episodes.StateDuration,'BinWidth',1);
xlabel('Episode Duration (s)');
ylabel('# Episodes');
set(gca,'FontSize',20);


end


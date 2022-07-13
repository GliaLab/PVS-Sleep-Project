function roa_stats(tp)
% 
% tp.reset();
% tp.has_roa = true;
% % tp.genotype = 'wt_dual';
% ts = tp.get_tseries();
% %%
% begonia.util.logging.backwrite()
% for i = 1:length(ts)
%     begonia.util.logging.backwrite(1,sprintf('roa_stats %d/%d',i,length(ts)));
%     
%     dx = ts(i).dx;
%     dt = ts(i).dt;
%     
%     % ROA ignore mask.
%     roa_ignore_mask = ts(i).load_var('roa_ignore_mask');
%     edge_ignore_width = 15;
%     roa_ignore_mask(1:edge_ignore_width,:) = true;
%     roa_ignore_mask(end-edge_ignore_width:end,:) = true;
%     roa_ignore_mask(:,1:edge_ignore_width) = true;
%     roa_ignore_mask(:,end-edge_ignore_width:end) = true;
%     % Flips it. Result is true where ROAs are allowed.
%     roa_ignore_mask = ~roa_ignore_mask;
%     
%     roa_mask = ts(i).load_var('roa_mask');
%     roa_mask = roa_mask & roa_ignore_mask;
%     
%     roa_density_trace = sum(sum(roa_mask,1),2)/sum(roa_ignore_mask(:));
%     roa_density_trace = squeeze(roa_density_trace);
%     
% %     roa_table = begonia.processing.extract_roa_events(roa_mask,dx,dt);
%     roa_table = ts(i).load_var('roa_table');
%     
%     roa_ignore_mask_area = sum(roa_ignore_mask(:)) * dx * dx;
%     
%     dur = seconds(ts(i).duration);
%     
%     t = 0:dt:dur;
%     roa_frequency_trace = histcounts(roa_table.roa_t_start,t) / dt / roa_ignore_mask_area;
%     ts(i).save_var(roa_ignore_mask_area);
%     ts(i).save_var(roa_table);
%     ts(i).save_var(roa_density_trace);
%     ts(i).save_var(roa_frequency_trace);
% end

end


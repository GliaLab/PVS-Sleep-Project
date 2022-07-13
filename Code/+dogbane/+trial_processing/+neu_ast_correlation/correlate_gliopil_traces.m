function correlate_gliopil_traces(trial)
%% 
tr = trial.rec_rig_trial;
ts = trial.tseries;

ts.clear_var('correlate_gliopil_traces');

if ~ts.has_var('ca_signal_gliopil_traces')
    return;
end

dt = ts.dt;
fs = 1/dt;

%%
roa_frequency_trace_Gp = ts.load_var('roa_frequency_trace_Gp',[]);
if ~isempty(roa_frequency_trace_Gp)
    roa_frequency_trace_Gp = convn(roa_frequency_trace_Gp,begonia.util.gausswin(7)','same');
    roa_frequency_trace_Gp = roa_frequency_trace_Gp * 60 * 100;
end

ca_signal_Gp_neu = ts.load_var('ca_signal_Gp_neu',[]);
if ~isempty(ca_signal_Gp_neu)
    ca_signal_Gp_neu = double(ca_signal_Gp_neu);
    ca_signal_Gp_neu = convn(ca_signal_Gp_neu,begonia.util.gausswin(7)','same');
    ca_signal_Gp_neu = round(ca_signal_Gp_neu,1);
    ca_signal_Gp_neu = ca_signal_Gp_neu / mode(ca_signal_Gp_neu) - 1;
end

%% 

ca_signal_gliopil_traces = ts.load_var('ca_signal_gliopil_traces');

% Calculate df/f0 and filter roi calcium signals
order = 4;

band = [0.5,2]; % Hz
band = band * 2 / fs;
[b_low_delta,a_low_delta] = butter(order,band,'bandpass');
band = [2,4]; % Hz
band = band * 2 / fs;
[b_high_delta,a_high_delta] = butter(order,band,'bandpass');
band = [0.5,4]; % Hz
band = band * 2 / fs;
[b_delta,a_delta] = butter(order,band,'bandpass');
band = [5,9]; % Hz
band = band * 2 / fs;
[b_theta,a_theta] = butter(order,band,'bandpass');
band = [9,14]; % Hz
band = band * 2 / fs;
[b_sigma,a_sigma] = butter(order,band,'bandpass');

% update the ca_signal_gliopil_traces table with more versions of the
% traces. 
for i = 1:length(ca_signal_gliopil_traces)
    
    ast = ca_signal_gliopil_traces(i).ast;
    ast = round(ast,1);
    ast = ast / mode(ast) - 1;
    ca_signal_gliopil_traces(i).ast = ast;
    
    neu = ca_signal_gliopil_traces(i).neu;
    neu = round(neu,1);
    neu = neu / mode(neu) - 1;
    ca_signal_gliopil_traces(i).neu = neu;
    
    % low delta
    trace = filtfilt(b_low_delta, a_low_delta, ast);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).ast_low_delta = trace;
    
    trace = filtfilt(b_low_delta, a_low_delta, neu);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).neu_low_delta = trace;
    
    % high delta
    trace = filtfilt(b_high_delta, a_high_delta, ast);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).ast_high_delta = trace;
    
    trace = filtfilt(b_high_delta, a_high_delta, neu);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).neu_high_delta = trace;
    
    % delta
    trace = filtfilt(b_delta, a_delta, ast);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).ast_delta = trace;
    
    trace = filtfilt(b_delta, a_delta, neu);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).neu_delta = trace;
    
    % theta
    trace = filtfilt(b_theta, a_theta, ast);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).ast_theta = trace;
    
    trace = filtfilt(b_theta, a_theta, neu);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).neu_theta = trace;
    
    % sigma
    trace = filtfilt(b_sigma, a_sigma, ast);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).ast_sigma = trace;
    
    trace = filtfilt(b_sigma, a_sigma, neu);
    trace = abs(hilbert(trace)).^2;
    ca_signal_gliopil_traces(i).neu_sigma = trace;
end

ca_signal_gliopil_traces = struct2table(ca_signal_gliopil_traces);

trace_length = size(ca_signal_gliopil_traces.ast,2);

%%
tbl_states = tr.load_var('state_episodes');

tbl_states.start_idx = round(tbl_states.StateStart * fs) + 1;
tbl_states.end_idx = round(tbl_states.StateEnd * fs);

tbl_states.state = tbl_states.State;
tbl_states.state_duration = tbl_states.StateDuration;
tbl_states.state_start = tbl_states.StateStart;
tbl_states.state_end = tbl_states.StateEnd;

tbl_states.corr = nan(height(tbl_states),1);
tbl_states.corr_lag = nan(height(tbl_states),1);

tbl_states.low_delta_corr = nan(height(tbl_states),1);
tbl_states.low_delta_corr_lag = nan(height(tbl_states),1);

tbl_states.high_delta_corr = nan(height(tbl_states),1);
tbl_states.high_delta_corr_lag = nan(height(tbl_states),1);

tbl_states.delta_corr = nan(height(tbl_states),1);
tbl_states.delta_corr_lag = nan(height(tbl_states),1);

tbl_states.theta_corr = nan(height(tbl_states),1);
tbl_states.theta_corr_lag = nan(height(tbl_states),1);

tbl_states.sigma_corr = nan(height(tbl_states),1);
tbl_states.sigma_corr_lag = nan(height(tbl_states),1);

tbl_states.roa_neu_corr = nan(height(tbl_states),1);
tbl_states.roa_neu_corr_lag = nan(height(tbl_states),1);

%%
for i = 1:height(tbl_states)
    st = tbl_states.start_idx(i);
    en = tbl_states.end_idx(i);
    
    if tbl_states.State(i) == 'undefined'
        continue;
    end

    if en > trace_length
        en = trace_length;
    end
    
    corr = nan(height(ca_signal_gliopil_traces),1);
    corr_lag = nan(height(ca_signal_gliopil_traces),1);
    
    low_delta_corr = nan(height(ca_signal_gliopil_traces),1);
    low_delta_corr_lag = nan(height(ca_signal_gliopil_traces),1);
    
    high_delta_corr = nan(height(ca_signal_gliopil_traces),1);
    high_delta_corr_lag = nan(height(ca_signal_gliopil_traces),1);
    
    delta_corr = nan(height(ca_signal_gliopil_traces),1);
    delta_corr_lag = nan(height(ca_signal_gliopil_traces),1);
    
    theta_corr = nan(height(ca_signal_gliopil_traces),1);
    theta_corr_lag = nan(height(ca_signal_gliopil_traces),1);
    
    sigma_corr = nan(height(ca_signal_gliopil_traces),1);
    sigma_corr_lag = nan(height(ca_signal_gliopil_traces),1);
    
    roa_neu_cor = nan(height(ca_signal_gliopil_traces),1);
    roa_neu_cor_lag = nan(height(ca_signal_gliopil_traces),1);
    
    for j = 1:height(ca_signal_gliopil_traces)
        ast = ca_signal_gliopil_traces.ast(j,st:en)';
        neu = ca_signal_gliopil_traces.neu(j,st:en)';
        
        ast_low_delta = ca_signal_gliopil_traces.ast_low_delta(j,st:en)';
        neu_low_delta = ca_signal_gliopil_traces.neu_low_delta(j,st:en)';
        
        ast_high_delta = ca_signal_gliopil_traces.ast_high_delta(j,st:en)';
        neu_high_delta = ca_signal_gliopil_traces.neu_high_delta(j,st:en)';
        
        ast_delta = ca_signal_gliopil_traces.ast_delta(j,st:en)';
        neu_delta = ca_signal_gliopil_traces.neu_delta(j,st:en)';
        
        ast_theta = ca_signal_gliopil_traces.ast_theta(j,st:en)';
        neu_theta = ca_signal_gliopil_traces.neu_theta(j,st:en)';
        
        ast_sigma = ca_signal_gliopil_traces.ast_sigma(j,st:en)';
        neu_sigma = ca_signal_gliopil_traces.neu_sigma(j,st:en)';

        if isempty(ast)
            continue;
        end

        % Correlation
        [c,lag] = crosscorr(ast,neu);
        [c,I] = max(abs(c));
        lag = lag(I);
        corr(j) = c;
        corr_lag(j) = lag;
        
        % Correlation low delta
        [c,lag] = crosscorr(ast_low_delta,neu_low_delta);
        [c,I] = max(abs(c));
        lag = lag(I);
        low_delta_corr(j) = c;
        low_delta_corr_lag(j) = lag;
        
        % Correlation high delta
        [c,lag] = crosscorr(ast_high_delta,neu_high_delta);
        [c,I] = max(abs(c));
        lag = lag(I);
        high_delta_corr(j) = c;
        high_delta_corr_lag(j) = lag;
        
        % Correlation delta
        [c,lag] = crosscorr(ast_delta,neu_delta);
        [c,I] = max(abs(c));
        lag = lag(I);
        delta_corr(j) = c;
        delta_corr_lag(j) = lag;
        
        % Correlation theta
        [c,lag] = crosscorr(ast_theta,neu_theta);
        [c,I] = max(abs(c));
        lag = lag(I);
        theta_corr(j) = c;
        theta_corr_lag(j) = lag;
        
        % Correlation sigma
        [c,lag] = crosscorr(ast_sigma,neu_sigma);
        [c,I] = max(abs(c));
        lag = lag(I);
        sigma_corr(j) = c;
        sigma_corr_lag(j) = lag;
        
%         f = figure;
%         f.Position(3:4) = [800,1200];
%         ax(1) = subplot(4,1,1);
%         hold on
%         p(1) = plot((0:length(neu)-1)*dt,neu,'DisplayName','neu');
%         p(2) = plot((0:length(ast)-1)*dt,ast,'DisplayName','ast');
%         legend(p)
%         
%         ax(2) = subplot(4,1,2);
%         hold on
%         p(1) = plot((0:length(neu_delta)-1)*dt,neu_delta,'DisplayName','neu');
%         p(2) = plot((0:length(ast_delta)-1)*dt,ast_delta,'DisplayName','ast');
%         legend(p)
%         
%         ax(3) = subplot(4,1,3);
%         hold on
%         p(1) = plot((0:length(neu_theta)-1)*dt,neu_theta,'DisplayName','neu');
%         p(2) = plot((0:length(ast_theta)-1)*dt,ast_theta,'DisplayName','ast');
%         legend(p)
%         
%         ax(4) = subplot(4,1,4);
%         hold on
%         p(1) = plot((0:length(neu_sigma)-1)*dt,neu_sigma,'DisplayName','neu');
%         p(2) = plot((0:length(ast_sigma)-1)*dt,ast_sigma,'DisplayName','ast');
%         legend(p)
%         linkaxes(ax,'x');
%         uiwait
    end
    
    tbl_states.corr(i) = nanmean(corr);
    tbl_states.low_delta_corr(i) = nanmean(low_delta_corr);
    tbl_states.high_delta_corr(i) = nanmean(high_delta_corr);
    tbl_states.delta_corr(i) = nanmean(delta_corr);
    tbl_states.theta_corr(i) = nanmean(theta_corr);
    tbl_states.sigma_corr(i) = nanmean(sigma_corr);
    
    tbl_states.corr_lag(i) = nanmean(corr_lag) * dt;
    tbl_states.low_delta_corr_lag(i) = nanmean(low_delta_corr_lag) * dt;
    tbl_states.high_delta_corr_lag(i) = nanmean(high_delta_corr_lag) * dt;
    tbl_states.delta_corr_lag(i) = nanmean(delta_corr_lag) * dt;
    tbl_states.theta_corr_lag(i) = nanmean(theta_corr_lag) * dt;
    tbl_states.sigma_corr_lag(i) = nanmean(sigma_corr_lag) * dt;
    
    % Correlation between ROA and neuropil.
    if ~isempty(ca_signal_Gp_neu) && ~isempty(roa_frequency_trace_Gp)
        [c,lag] = crosscorr(ca_signal_Gp_neu(st:en),roa_frequency_trace_Gp(st:en));
        [c,I] = max(abs(c));
        lag = lag(I);
    else
        c = nan;
        lag = nan;
    end
    tbl_states.roa_neu_corr(i) = c;
    tbl_states.roa_neu_corr_lag(i) = lag * dt;
end

tbl_states(tbl_states.State == 'undefined',:) = [];

%%
tbl_states.State = [];
tbl_states.StateDuration = [];
tbl_states.StateStart = [];
tbl_states.StateEnd = [];
tbl_states.PreviousState = [];
tbl_states.PreviousStateDuration = [];
tbl_states.PreviousStateStart = [];
tbl_states.PreviousStateEnd = [];
tbl_states.start_idx = [];
tbl_states.end_idx = [];

correlate_gliopil_traces = tbl_states;

ts.save_var(correlate_gliopil_traces);
end


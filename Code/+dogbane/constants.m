classdef constants
    
    properties (Constant)
        
        excluded_trials = {};
        
        % From ip3.xlsx AND Tseries_ignored.xlsx AND 4 from Laura Slack
        excluded_tseries = { ...
            'TSeries-06162017-1006-016', ...
            'TSeries-06182017-0943-013', ...
            'TSeries-06182017-0943-014', ...
            'TSeries-06192017-0850-004', ...
            'TSeries-06212017-0925-002', ...
            'TSeries-06212017-0925-003', ...
            'TSeries-06212017-0925-004', ...
            'TSeries-06212017-0925-005', ...
            'TSeries-06212017-0925-006', ...
            'TSeries-06212017-0925-007', ...
            'TSeries-06212017-0925-008', ...
            'TSeries-06212017-0925-009', ...
            'TSeries-06212017-0925-010', ...
            'TSeries-06212017-0925-011', ...
            'TSeries-06212017-0925-012', ...
            'TSeries-06212017-0925-014', ...
            'TSeries-06212017-0925-016', ...
            'TSeries-01162018-1014-001', ...
            'TSeries-01162018-1014-004', ...
            'TSeries-01192018-0917-005', ...
            'TSeries-01192018-0917-006', ...
            'TSeries-01212018-1158-015', ...
            'TSeries-02022018-0941-012', ...
            'TSeries-02102018-0917-013', ...
            'TSeries-02212018-0921-013', ...
            'TSeries-02282018-0823-004', ...
            'TSeries-09062018-0958-020', ...
            'TSeries-09072018-0950-010', ...
            'TSeries-09072018-0950-023', ...
            'TSeries-09112018-0914-015', ...
            'TSeries-01212018-1158-006', ...
            };
        
        % From Laura over slack
        excluded_roa_tseries = {};
        
        % From ROAignored.xlsx
        excluded_roa_trials = {...
            '20180115_TR16_trial_004'  , ...
            '20180115_TR16_trial_006'  , ...
            '20180116_TR15_trial_004'  , ...
            '20180117_TR16_trial_016'  , ...
            '20180118_BL15_trial_015'  , ...
            '20180118_BL15_trial_016'  , ...
            '20180118_BL15_trial_017'  , ...
            '20180118_BL15_trial_018'  , ...
            '20180119_NM16_trial_001'  , ...
            '20180119_NM16_trial_005'  , ...
            '20180119_NM16_trial_012'  , ...
            '20180119_NM16_trial_014'  , ...
            '20180120_TL16_trial_011'  , ...
            '20180121_TL15_trial_003'  , ...
            '20180121_TL15_trial_004'  , ...
            '20180121_TL15_trial_006'  , ...
            '20180121_TL15_trial_008'  , ...
            '20180121_TL15_trial_010'  , ...
            '20180121_TL15_trial_011'  , ...
            '20180121_TL15_trial_013'  , ...
            '20180130_TR15_trial_009'  , ...
            '20180202_TL15_trial_016'  , ...
            '20180203_TL16_trial_019'  , ...
            '20180203_TL16_trial_025'  , ...
            '20180203_TL16_trial_027'  , ...
            '20180204_TR15_trial_003'  , ...
            '20180205_TL15_trial_016'  , ...
            '20180208_NM16_trial_003'  , ...
            '20180208_NM16_trial_004'  , ...
            '20180210_TR16_trial_003'  , ...
            '20180210_TR16_trial_008'  , ...
            '20180210_TR16_trial_011'  , ...
            '20180210_TR16_trial_012'  , ...
            '20180210_TR16_trial_013'  , ...
            '20180210_TR16_trial_014'  , ...
            '20180210_TR16_trial_015'  , ...
            '20180211_TL16_trial_001'  , ...
            '20180211_TL16_trial_002'  , ...
            '20180211_TL16_trial_003'  , ...
            '20180211_TL16_trial_007'  , ...
            '20180211_TL16_trial_008'  , ...
            '20180214_TL15_trial_009'  , ...
            '20180214_TL15_trial_010'  , ...
            '20180214_TL15_trial_011'  , ...
            '20180214_TL15_trial_012'  , ...
            '20180214_TL15_trial_013'  , ...
            '20180214_TL15_trial_014'  , ...
            '20180214_TL15_trial_018'  , ...
            '20180214_TL15_trial_019'  , ...
            '20180214_TL15_trial_020'  , ...
            '20180215_BL15_trial_001'  , ...
            '20180215_BL15_trial_002'  , ...
            '20180215_BL15_trial_004'  , ...
            '20180215_BL15_trial_005'  , ...
            '20180215_BL15_trial_006'  , ...
            '20180215_BL15_trial_007'  , ...
            '20180215_BL15_trial_008'  , ...
            '20180215_BL15_trial_009'  , ...
            '20180215_BL15_trial_010'  , ...
            '20180215_BL15_trial_011'  , ...
            '20180215_BL15_trial_012'  , ...
            '20180215_BL15_trial_017'  , ...
            '20180221_TR15_trial_001'  , ...
            '20180221_TR15_trial_002'  , ...
            '20180221_TR15_trial_006'  , ...
            '20180221_TR15_trial_007'  , ...
            '20180221_TR15_trial_008'  , ...
            '20180221_TR15_trial_009'  , ...
            '20180221_TR15_trial_010'  , ...
            '20180221_TR15_trial_011'  , ...
            '20180221_TR15_trial_013'  , ...
            '20170616_BL15_1_trial_001', ...
            '20170616_BL15_1_trial_003', ...
            '20170616_BL15_1_trial_005', ...
            '20170616_BL15_1_trial_006', ...
            '20170616_BL15_1_trial_009', ...
            '20170616_BL15_1_trial_010', ...
            '20170616_BL15_1_trial_011', ...
            '20170616_BL15_1_trial_012', ...
            '20170616_BL15_2_trial_002', ...
            '20170616_BL15_2_trial_004', ...
            '20170616_BL15_2_trial_005', ...
            '20170616_BL15_3_trial_003', ...
            '20170616_BL15_3_trial_004', ...
            '20170616_BL15_3_trial_005', ...
            '20170618_BL16_trial_001'  , ...
            '20170618_BL16_trial_002'  , ...
            '20170618_BL16_trial_004'  , ...
            '20170618_BL16_trial_005'  , ...
            '20170618_BL16_trial_006'  , ...
            '20170618_BL16_trial_008'  , ...
            '20170618_BL16_trial_009'  , ...
            '20170618_BL16_trial_016'  , ...
            '20170619_TR15_trial_005'  , ...
            '20170621_092550_trial_002', ...
            '20170621_092550_trial_003', ...
            '20170621_092550_trial_004', ...
            '20170621_092550_trial_005', ...
            '20170621_092550_trial_006', ...
            '20170621_092550_trial_007', ...
            '20170621_092550_trial_008', ...
            '20170621_092550_trial_009', ...
            '20170621_092550_trial_010', ...
            '20170621_092550_trial_011', ...
            '20170621_092550_trial_012', ...
            '20170621_092550_trial_013', ...
            '20170621_092550_trial_014', ...
            '20170621_092550_trial_015', ...
            '20170621_092550_trial_016', ...
            '20170621_092550_trial_017', ...
            '20170621_092550_trial_018', ...
            '20170621_092550_trial_020', ...
            '20170621_171456_trial_002', ...
            '20170621_171456_trial_003', ...
            '20180225_NM16_trial_007'  , ...
            '20180225_TL16_trial_012'  , ...
            '20180225_TL16_trial_013'  , ...
            '20180225_TL16_trial_014'  , ...
            '20180226_BL15_trial_001'  , ...
            '20180226_BL15_trial_002'  , ...
            '20180226_BL15_trial_003'  , ...
            '20180226_BL15_trial_004'  , ...
            '20180226_BL15_trial_005'  , ...
            '20180226_BL15_trial_006'  , ...
            '20180228_TL15_trial_004'  , ...
            '20180228_TL15_trial_005'  , ...
            '20180304_TR15_trial_009'  , ...
            '20180304_TR15_trial_010'  , ...
            '20180304_TR15_trial_012'  , ...
            '20180305_TR16_trial_013'  , ...
            '20180305_TR16_trial_019'  , ...
            '20180305_TR16_trial_020'  , ...
            '20180306_TL16_trial_002'  , ...
            '20180306_TL16_trial_014'  , ...
            '20180306_TL16_trial_015'  , ...
            '20180306_TL16_trial_020'  , ...
            '20180306_TL16_trial_021'  , ...
            '20180809_TL_trial_010'    , ...
            '20180809_TL_trial_011'    , ...
            '20180809_TL_trial_013'    , ...
            '20180809_TL_trial_029'    , ...
            '20180816_TL_trial_011'    , ...
            '20180816_TL_trial_016'    , ...
            '20180816_TL_trial_018'    , ...
            '20180817_NM_trial_006'    , ...
            '20180817_NM_trial_008'    , ...
            '20180817_NM_trial_016'    , ...
            '20180817_NM_trial_019'    , ...
            '20180817_NM_trial_020'    , ...
            '20180817_NM_trial_021'    , ...
            '20180817_NM_trial_023'    , ...
            '20180819_TR_trial_007'    , ...
            '20180819_TR_trial_008'    , ...
            '20180819_TR_trial_011'    , ...
            '20180819_TR_trial_012'    , ...
            '20180820_TL_trial_017'    , ...
            '20180821_NM_trial_007'    , ...
            '20180821_NM_trial_013'    , ...
            '20180821_NM_trial_016'    , ...
            '20180828_TR_trial_009'    , ...
            '20180828_TR_trial_017'    , ...
            '20180830_TL_trial_010'    , ...
            '20180830_TL_trial_018'    , ...
            '20180830_TL_trial_023'    , ...
            '20180830_TL_trial_026'    , ...
            '20180830_TL_trial_027'    , ...
            '20180830_TL_trial_028'    , ...
            '20180902_NM_trial_012'    , ...
            '20180902_NM_trial_013'    , ...
            '20180902_NM_trial_014'    , ...
            '20180902_NM_trial_015'    , ...
            '20180902_NM_trial_017'    , ...
            '20180902_NM_trial_019'    , ...
            '20180902_NM_trial_020'    , ...
            '20180902_NM_trial_021'    , ...
            '20180906_TR_trial_006'    , ...
            '20180906_TR_trial_013'    , ...
            '20180906_TR_trial_017'    , ...
            '20180906_TR_trial_018'    , ...
            '20180906_TR_trial_019'    , ...
            '20180906_TR_trial_021'    , ...
            '20180907_NM_trial_005'    , ...
            '20180907_NM_trial_006'    , ...
            '20180907_NM_trial_010'    , ...
            '20180907_NM_trial_015'    , ...
            '20180907_NM_trial_022'    , ...
            '20180907_NM_trial_023'    , ...
            '20180907_NM_trial_024'    , ...
            '20180907_NM_trial_025'    , ...
            '20180907_NM_trial_029'    , ...
            '20180909_TR_trial_002'    , ...
            '20180909_TR_trial_003'    , ...
            '20180911_TR_trial_002'    , ...
            '20180911_TR_trial_006'    , ...
            '20180911_TR_trial_012'    , ...
            '20180911_TR_trial_015'    , ...
            '20180911_TR_trial_016'    , ...
            '20180911_TR_trial_019'    , ...
            '20180911_TR_trial_020'    , ...
            '20180911_TR_trial_023'    , ...
            '20180918_TL_trial_017'    , ...
            '20180918_TL_trial_018'    , ...
            '20180918_TL_trial_019'    , ...
            '20180918_TL_trial_024'    , ...
            '20180918_TL_trial_027'    , ...
            '20180920_NM_trial_001'    , ...
            '20180920_NM_trial_002'    , ...
            '20180920_NM_trial_003'    , ...
            '20180920_NM_trial_004'    , ...
            '20180920_NM_trial_005'    , ...
            '20180920_NM_trial_006'    , ...
            '20180920_NM_trial_007'    , ...
            '20180920_NM_trial_008'    , ...
            '20180927_TR_trial_001'    , ...
            };
        
        % From ip3.xlsx excluded overall
%         excluded_tseries = { ...
%             'TSeries-06162017-1006-016', ...
%             'TSeries-06182017-0943-013', ...
%             'TSeries-06182017-0943-014', ...
%             'TSeries-06192017-0850-004', ...
%             'TSeries-06212017-0925-002', ...
%             'TSeries-06212017-0925-003', ...
%             'TSeries-06212017-0925-004', ...
%             'TSeries-06212017-0925-005', ...
%             'TSeries-06212017-0925-006', ...
%             'TSeries-06212017-0925-007', ...
%             'TSeries-06212017-0925-008', ...
%             'TSeries-06212017-0925-009', ...
%             'TSeries-06212017-0925-010', ...
%             'TSeries-06212017-0925-011', ...
%             'TSeries-06212017-0925-012', ...
%             'TSeries-06212017-0925-014', ...
%             'TSeries-06212017-0925-016', ...
%             };
        
        % From laura excluded overall (Tseries_ignored.xlsx)
%         excluded_tseries = { ...
%             'TSeries-01162018-1014-001', ...
%             'TSeries-01162018-1014-004', ...
%             'TSeries-01192018-0917-005', ...
%             'TSeries-01192018-0917-006', ...
%             'TSeries-01212018-1158-015', ...
%             'TSeries-02022018-0941-012', ...
%             'TSeries-02102018-0917-013', ...
%             'TSeries-02212018-0921-013', ...
%             'TSeries-02282018-0823-004', ...
%             };
        
        genotypes = {'wt_dual','wt_lck','ip3_dual'};
        
        roi_group_names = {'AS','Gp','Ca','Ve','Ar','AE','NS'};
        
        state_names_long = { ...
            'Undefined', ...
            'Locomotion', ...
            'Whisking', ...
            'Quiet wake', ...
            'NREM', ...
            'IS', ...
            'REM', ...
            'Awakening', ...
            'Motion', ...
            'Sleep', ...
            'Wake', ...
            'Twitching', ...
            };
        
        state_names = {...
            'undefined', ...
            'locomotion', ...
            'whisking', ...
            'quiet', ...
            'nrem', ...
            'is', ...
            'rem', ...
            'awakening', ...
            'motion', ... 
            'sleep', ...
            'wake', ...
            'twitching', ...
            };
        
        state_colors = [...
            0.5765,0.8157,0.9529 ; ...  % undefined
            0.0078,0.0510,0.4902 ; ...  % locomotion
            0.1176,0.5098,0.9804 ; ...  % whisking
            0.4196,0.8039,0.9882 ; ...  % qw
            0.0000,0.0000,0.0000 ; ...  % nrem
            0.4275,0.4275,0.4275 ; ...  % is
            0.7020,0.7020,0.7020 ; ...  % rem
            0.4980,0.0588,0.4941 ; ...  % awakening
            0.1176,0.5098,0.9804 ; ...  % motion
            1.0000,0.0000,1.0000 ; ...  % sleep
            1.0000,0.0000,0.0000 ; ...  % wake
            0.1282,0.5651,0.5509 ; ...  % twitching
            ];
        
        peak_type_names = {'singlepeak', 'multipeak', 'plateau','subpeak'};
        peak_type_count = length(dogbane.constants.peak_type_names);
        
        SLEEP = 1;
        REM = 2;
        NREM = 3;
        IS = 4;
        AWAKENING = 5;
        WAKE = 6;
        QUIET = 7;
        WHISKING = 8;
        LOCOMOTION = 9;
        MOTION = 10;
        TWITCHING = 11;
        
        N_STATES = 11;
    end
    
    methods (Static)
        function names_long = state_names_short2long(names_short)
            % Convert from short naming to long naming.
            % Preserves the categories.
            % Output is the same class as input.
            
            input_class = class(names_short);
            switch input_class
                case 'categorical'
                    % pass
                case 'char'
                    names_short = categorical({names_short});
                case 'cell'
                    names_short = categorical(names_short);
                otherwise
                    error('Wrong input.')
            end
            
            old_cats = categories(names_short);
            new_cats = cell(size(old_cats));
            for i = 1:length(old_cats)
                strs_old = strsplit(old_cats{i},':');
                strs_new = cell(size(strs_old));
                for j = 1:length(strs_old)
                    I = strcmp(strs_old{j},dogbane.constants.state_names);
                    assert(any(I),sprintf('Invalid state ''%s''.',strs_old{j}));
                    strs_new{j} = dogbane.constants.state_names_long{I};
                end
                str = sprintf('%s & ',strs_new{:});
                str(end-2:end) = [];
                new_cats{i} = str;
            end
            
            names_long = renamecats(names_short,new_cats);
            
            switch input_class
                case 'categorical'
                    % pass
                case 'char'
                    names_long = cellstr(names_long);
                    names_long = names_long{1};
                case 'cell'
                    names_long = cellstr(names_long);
            end
        end
        
        
        function colors = state_names_short2colors(names_short)
            input_class = class(names_short);
            switch input_class
                case 'categorical'
                    names_short = cellstr(names_short);
                case 'char'
                    names_short = {names_short};
                case 'cell'
                    %pass
                otherwise
                    error('Wrong input.')
            end
                   
            colors = zeros(length(names_short),3);
            for i = 1:length(names_short)
                strs = strsplit(names_short{i},':');
                mat = zeros(length(strs),3);
                for j = 1:length(strs)
                    I = strcmp(dogbane.constants.state_names,strs{j});
                    mat(j,:) = dogbane.constants.state_colors(I,:);
                end
                colors(i,:) = mean(mat,1);
%                 I = strcmp(dogbane.constants.state_names,strs{end});
%                 colors(i,:) = dogbane.constants.state_colors(I,:);
            end
        end
    end
    
end


function states = states_mat2states(self,states_mat)
%% transform the columns from binary to decimal.
states_mat = num2str(states_mat,'%d');
states_num = bin2dec(states_mat')';
%% Transform the numbers to a categorical vector 
% val_set and cat_set is defined in the private function 'init'.
states = categorical(states_num,self.val_set,self.cat_set);
%% Check if there is any unexpected outputs

% Only check if expected outputs have been set
if ~isempty(self.expected_outputs)
    states = setcats(states,self.expected_outputs);
    
    I = find(isundefined(states),1,'first');
    if ~isempty(I)
        idx = states_num(I) + 1;
        str = self.cat_set(idx);
        str = char(str);
        error('Unexpected combination of states : %s ',str);
    end
end

states = removecats(states);
end
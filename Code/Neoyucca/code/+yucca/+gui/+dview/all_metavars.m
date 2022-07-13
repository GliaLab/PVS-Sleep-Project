function [ vars ] = all_metavars( data )
%ALL_METAVARS When given a list of DataLocation objects, this will get all
%the unique var names on those objects (no duplicates)
%   Detailed explanation goes here
    vars = unique(vertcat(data.saved_vars))';
end


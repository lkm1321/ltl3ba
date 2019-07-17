function BA = ltl3ba(formula)

    clear ltl3ba_cpp; 
    hoaf_str = ltl3ba_cpp(formula); 
    clear ltl3ba_cpp; % this is necessary!
    
    %% Parsing the header. 
    % get the number of states
    num_states = get_num_states(hoaf_str); 
    
    % get the number of APs and their names. 
    [num_aps, ap_names] = get_aps(hoaf_str); 

    % set up the graph. 
    BA = digraph;
    BA = addnode(BA, num_states);
    BA.Nodes.StateNo = (0:(num_states-1))'; 
    BA.Nodes.StateName = cell(num_states, 1); 
    BA.Edges.Condition = cell(0, 1); 

    %% Parsing the body text. 

    % get the body text. 
    body_text = get_body_text(hoaf_str); 
    
    % split by state
    body_contents = split(body_text, 'State: '); 
    
    % matlab always returns empty cell at the start. 
    body_contents = body_contents(2:end); 

    % for each state
    for iState = 1:length(body_contents)
        
        % split into lines. line 1 gives details about the state itself. 
        body_lines = splitlines(body_contents{iState}); 

        % find enclosed in quote. this is the name of state e.g. init. 
        quote_idx = strfind(body_lines{1}, '"'); 
        
        % get the name of state in. 
        BA.Nodes.StateName{iState} = body_lines{1}( (quote_idx(1)+1):(quote_idx(2)-1)); 
        
        for iEdges = 2:length(body_lines)

            % find enclosed between square brackets. 
            bracket_op = strfind(body_lines{iEdges}, '['); 
            bracket_cl = strfind(body_lines{iEdges}, ']'); 

            edge_condition = body_lines{iEdges}(bracket_op+1:bracket_cl-1); 

            % replace 0 and 1 with the AP names. 
            for iAps = 1:num_aps
                edge_condition = strrep(edge_condition, int2str(iAps-1), ap_names{iAps}); 
            end
            
            % the next BA state this edge is pointing to. 
            neighbour = str2num( body_lines{iEdges}(bracket_cl+1:end) ); 

            % add the edge. 
            BA = addedge(BA, iState, neighbour + 1, table({edge_condition}, 'VariableNames', {'Condition'}) );
        end
    end
    
function num_states = get_num_states(hoaf_str)

    num_states_str = 'States: '; 

    [num_states_idx] = strfind(hoaf_str, num_states_str); 
    num_states_line = splitlines(hoaf_str(num_states_idx:end)); 
    num_states_line = num_states_line{1}; 
    num_states = str2num(num_states_line(length(num_states_str)+1:end)); 
    
function [num_aps, ap_names] = get_aps(hoaf_str)

    num_aps_str = 'AP: '; 

    [num_aps_idx] = strfind(hoaf_str, num_aps_str); 
    num_aps_line = splitlines(hoaf_str(num_aps_idx:end));
    num_aps_line = num_aps_line{1}; 
    
    [num_aps, ~, ~, next_index] = sscanf(num_aps_line, [num_aps_str, '%d ']); 
    
    ap_names = split(num_aps_line(next_index:end), " "); 
    
function body_text = get_body_text(hoaf_str)
    
    body_start_str = '--BODY--';
    body_end_str = '--END--';
    start_idx = strfind(hoaf_str, body_start_str); 
    start_idx = start_idx + length(body_start_str); 
    end_idx = strfind(hoaf_str, body_end_str); 
    
    body_text = hoaf_str(start_idx + 1:(end_idx-1)); 

      
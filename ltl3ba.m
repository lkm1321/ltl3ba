function BA = ltl3ba(formula)

    hoaf_str = ltl3ba_cpp(formula); 
    clear ltl3ba_cpp; % this is necessary!
    num_states = get_num_states(hoaf_str); 
    [num_aps, ap_names] = get_aps(hoaf_str); 
    body_text = get_body_text(hoaf_str); 
    
    BA = digraph;
    BA = addnode(BA, num_states);
    BA.Nodes.StateNo = (0:(num_states-1))'; 
    BA.Nodes.StateName = cell(num_states, 1); 
    BA.Edges.Condition = cell(0, 1); 
    
    body_contents = split(body_text, 'State: '); 
    body_contents = body_contents(2:end); 
    
    for iState = 1:length(body_contents)
        body_lines = splitlines(body_contents{iState}); 
        
        for iEdges = 2:length(body_lines)
            bracket_op = strfind(body_lines{iEdges}, '['); 
            bracket_cl = strfind(body_lines{iEdges}, ']'); 
            edge_name = body_lines{iEdges}(bracket_op+1:bracket_cl-1); 
            neighbour = str2num( body_lines{iEdges}(bracket_cl+1:end) ); 
            BA = addedge(BA, iState, neighbour + 1, );
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

      
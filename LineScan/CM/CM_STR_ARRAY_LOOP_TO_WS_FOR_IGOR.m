function CM_STR_ARRAY_LOOP_TO_WS_FOR_IGOR (Str_ArrayList)

if isempty (Str_ArrayList)
[Str_ArrayList] = CM_Choose_multiple_var('cell','Get Structures to analyse');
end
for counter=1:1:size(Str_ArrayList,2)
    Str_ArrayName=char(Str_ArrayList (counter));
    tac=evalin('base',Str_ArrayName);

    CM_STR_ARRAY_TO_WS_FOR_IGOR (tac,Str_ArrayName)
    
end
[files_to_open]=CM_loop_the_data_out_of_STRUCTURE_ALL('\ANALOG.mat','Analog_ST','.LIGHT_DATA','LIGHT_STIM','') ;
[files_to_open]=CM_loop_the_data_out_of_STRUCTURE_ALL('\ANALOG.mat','Analog_ST','.LIGHT_TIME','LIGHT_TIME',files_to_open) ;
%[files_to_open]=CM_loop_the_data_out_of_STRUCTURE_ALL('\ANALOG.mat','Analog_ST','.ACC_DATA','ACCELO',files_to_open) ;
%[files_to_open]=CM_loop_the_data_out_of_STRUCTURE_ALL('\ANALOG.mat','Analog_ST','.ACC_DATA','LFPData',files_to_open) ;
[files_to_open]=CM_loop_the_data_out_of_STRUCTURE_ALL('\ANALOG.mat','Analog_ST','.LFP_DATA','LFPData',files_to_open) ;

end

function CM_STR_ARRAY_TO_WS_FOR_IGOR (Str_Array,Str_Array_name)
if (isempty(Str_Array))
    [Str_Array,Str_Array_name]=CM_uigetvar ('cell','Get Structure to analyse');
    if isempty (Str_Array)
        return
    end
end

if isempty (Str_Array_name)
    Str_Array_name=CM_FETCH_THE_STRING ('ARB_01','Corresponding arbscan name');
end
Str_Array_name=strrep (Str_Array_name,'ARB_SCAN','ARB');
k=strfind(Str_Array_name,'ARB_');
if isempty (k)
    return
else
    dbstop if error
    prefix=Str_Array_name(k:k+5);
end

for counter=1:1:size(Str_Array,2)
    temp_Struct=Str_Array {counter};
    CM_STR_TO_WS_FOR_IGOR (temp_Struct,prefix);
end

end


function CM_STR_TO_WS_FOR_IGOR(temp_Struct,prefix)
names = fieldnames(temp_Struct);

for counter=1:1:size(names,1)
    field_name_or= char(names (counter));
    field_name=[prefix '_' field_name_or];
    k=~isempty (strfind(field_name,'diameter_deg'));
    k=k+ ~isempty (strfind(field_name,'time_axis'));
  % k=k+ ~isempty (strfind(field_name,'Dark_Mean_int'));
    k=k+ ~isempty (strfind(field_name,'MAX_int'));
   %   k=k+ ~isempty (strfind(field_name,'ch4_Mean_int'));


    
    if (k>0)
        field_name=strrep(field_name, 'ch1','');
        field_name=strrep(field_name, 'ch2','');
        field_name=strrep(field_name, 'ch3','');
        field_name=strrep(field_name, 'ch4','');
        field_name=strrep(field_name, 'ch_1','');
        field_name=strrep(field_name, 'ch_2','');
        field_name=strrep(field_name, 'ch_3','');
        field_name=strrep(field_name, 'ch_4','');
        field_name=strrep(field_name, 'diameter_deg','_diam');
        field_name=strrep(field_name, 'time_axis','_time_axis');
        %field_name=strrep(field_name, 'Dark_Mean_int','_DARK');
        field_name=strrep(field_name, 'MAX_int','_MAX');
        field_name=strrep(field_name, 'Mean_int','_DARK');
        field_name=strrep(field_name, 'midline_vector','_MID');
        field_name=strrep(field_name, '__','_');
        field_name=strrep(field_name, '__','_');
        field_name=strrep(field_name, '__','_');
        field_name=strrep(field_name, '__','_');
        assignin('base',field_name,temp_Struct.(field_name_or));
    end
end
end
function [FETCHED_STRING]=CM_FETCH_THE_STRING (STRING_TO_FETCH,defstring)
% this function calls the prompt and returns a string (sAnswer)
% CM_FETCH_THE_STRING (STRING_TO_FETCH,defstring)
prompt = {STRING_TO_FETCH};
dlg_title = ['Enter ' STRING_TO_FETCH];
num_lines = 1;
FETCHED_STRING = inputdlg(prompt,dlg_title,num_lines,{defstring});
FETCHED_STRING=FETCHED_STRING(1);
FETCHED_STRING=(FETCHED_STRING{:});
end

function [varname] = CM_Choose_multiple_var(variableclass,window_title)

if (nargin > 2)
  error('UIGETVAR:multiple_arguments','Only 1 argument allowed for uigetvar')
elseif (nargin > 0) && ~(ischar(variableclass) || iscellstr(variableclass))
  error('UIGETVAR:string','variableclass must be a string or a cell array of strings')
elseif (nargin == 2) && ischar(variableclass)
  % only one class is provided. Just make it a cell
  % array to make things easier.
  variableclass = {variableclass};
elseif (nargin == 0)
  % no class was indicated, so list all variables
  variableclass = {};
end

par.varlist = evalin('base','whos');
if ~isempty(variableclass)
  k = cellfun(@(c) ~ismember(c,variableclass),{par.varlist.class});
  par.varlist(k) = [];
end

% set up the uigetvar gui ...

% open up a figure window
par.fig = figure('Color',[0.8 0.8 0.8], ...
  'Units','normalized', ...
  'Position',[.4 .3 .2 .5], ...
  'CloseRequestFcn',@(s,e) weAreDone('closed'), ...
  'MenuBar','none', ...
  'Name',['Pick ' window_title],'NumberTitle','off');

% h_list = uicontrol('style','list','max',size(varlist,1),...
%      'min',0,'Position',[20 20 300 400],...
%      'string',txt_cell_array);


% listbox of selected variables from the base workspace
par.vars = uicontrol('Parent',par.fig, ...
  'Units','normalized', ...
  'BackgroundColor',[1 1 1], ...
  'Position',[.1 .25 .8 .70], ...
  'String',{par.varlist.name}, ...
  'HorizontalAlignment','left', ...
  'Style','listbox', ...
  'FontSize',12, ...
  'Value',1, ...
  'max',size(par.varlist,1),...
  'min',0,...
  'TooltipString','Choose one variable from the base workspace');

% Cancel button
par.cancel = uicontrol('Parent',par.fig, ...
  'Units','normalized', ...
  'BackgroundColor',[1 .7 .7], ...
  'Position',[.2 .1 .2 .1], ...
  'String','Cancel', ...
  'HorizontalAlignment','center', ...
  'Style','pushbutton', ...
  'Callback',@(s,e) weAreDone('cancel'), ...
  'TooltipString','Cancel, returning no selected variable');

% Done button
par.done = uicontrol('Parent',par.fig, ...
  'Units','normalized', ...
  'BackgroundColor',[.7 1 .7], ...
  'Position',[.6 .1 .2 .1], ...
  'String','Done', ...
  'HorizontalAlignment','center', ...
  'Style','pushbutton', ...
  'Callback',@(s,e) weAreDone('done'), ...
  'TooltipString','Return the selected variable');

% set a uiwait, to not return anything until
% the done or cancel buttons were clicked.
uiwait

% ...........
% Dum, de dum. Get some coffee. Dawdle. Snooze.
% ...........

% uiresume will come back in right here.
% variable = par.variable;
varname = par.varname;

% remove the figure window
delete(par.fig)


% ==========================
% end of main function
% ==========================
% begin nested functions for callbacks
% ==========================

  function weAreDone(op)
    % all done. did we cancel or was something selected?
    
    % the selection was ...
    val = get(par.vars,'value');
    
    switch op
      case 'cancel'
        % return with nothing selected
        %par.variable = [];
        par.varname = '';
        
      case {'done' 'closed'}
        % a selection was made, so return that variable.
        % if more than one was selected, just take
        % the first.
        par.varname=[];
        for counter=1:1:size(val,2)
            
        % we need to return the variable name as well
        % as the contents
        par.varname{counter} = par.varlist(val(counter)).name;
       % par.variable = evalin('base',par.varname);
        end
    end % switch op
    
    % all done now
    uiresume
    
  end % function weAreDone

end % mainline
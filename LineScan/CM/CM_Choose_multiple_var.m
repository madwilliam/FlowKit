% allow to select multiple variables of the same type from workspace
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
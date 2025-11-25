% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template HAB_0D runscript
% Versions: 0.1 : D. Bianchi, Aug 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Some documentation will follow:
% 
% some documentation... ;)
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Notes
% dt: timestep in days
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Adds path for local functions
% addpath ./functions/

% Initialize the model
clear nit;
%close all;

% Biological module
% Options:
% 'omz' : Models simple anaerobic N cycle, forced by OM remineralization
nit.BioModule = 'omz';

% Experimental setup
% Options:
% 'batch' : models a batch culture (initial conditions experiment)
% 'chemostat' : models a chemostat setup (includes dissolved flow inputs/outputs)
%nit.ExpModule = 'batch';
nit.ExpModule = 'chemostat';

% Here, if needed, overrides default parameters for BioModules and SetUp
% The experiment will adopt these parameters, overriding defaults
% (use ['property',value] format)
% (leave an empty cell array {} for default)
%new_BioPar = {'param1',value1,'param2',value2};
%new_SetUp = {'param1',value1,'param2',value2};
new_BioPar = {};
new_SetUp = {};

% Initialize biological parameters
switch nit.BioModule
    case 'omz'
        nit = nit_biopar_omz(nit,new_BioPar{:});
    otherwise
        error(['Error (biological case not found)']);
end

% Setup experiment type (e.g. batch, chemostat, etc.)
switch nit.ExpModule
    case 'batch'
        nit = nit_setup_batch(nit,new_SetUp{:});
    case 'chemostat'
        nit = nit_setup_chemo(nit,new_SetUp{:});
    otherwise
        error(['Error (experiment case not found)']);
end

% Run the model
nit = nit_integrate(nit);

% Some postprocessing -- adds diagnostics and reduces output time step
nit = nit_postprocess(nit,'dt_new',1);

% Plotting
iplot = 1;
if (iplot)
    switch nit.BioModule
        case 'omz'
            nit_plot_all(nit,'names',{'Sol'},'iAll',1); %Plot model - tracers only
            %nit_plot_all(nit,'names',{'Sol','Diag','Diag2'}); %Plot model - all diagnostics
        otherwise
            error(['Error (Processing not found)']);
    end
end


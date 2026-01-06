function BioPar = hab_initialize_omz(BioPar,ExpModule)

% Sets initial and boundary conditions for biological variables
% Distinguishes between the various physical setups
% Variables (from "biopar")
%  BioPar.varnames = {'o2','no3','doc','po4','n2o','nh4','no2','n2'};

switch ExpModule
    case {'batch','chemostat'}
        % Model variables: set initial values
        %-------------------------------------------
        % Tracers:
        BioPar.o2_0 = 5.0;		% In mmol/m3
        BioPar.no3_0 = 32;		% In mmol/m3
        
        % add variable OM/doc supply?
        BioPar.doc_0 = 30;		% In mmol/m3

        BioPar.po4_0 = 2;		% In mmol/m3
        BioPar.n2o_0 = 0;		% In mmol/m3
        BioPar.nh4_0 = 0;		% In mmol/m3
        BioPar.no2_0 = 0;		% In mmol/m3
        BioPar.n2_0 = 0;		% In mmol/m3


        % Model variables: set input values
        %-------------------------------------------
        % Tracers:
        BioPar.o2_in = BioPar.o2_0;		% In mmol/m3
        BioPar.no3_in = BioPar.no3_0;	% In mmol/m3
        BioPar.doc_in = BioPar.doc_0;	% In mmol/m3
        BioPar.po4_in = BioPar.po4_0;	% In mmol/m3
        BioPar.n2o_in = BioPar.n2o_0;	% In mmol/m3
        BioPar.nh4_in = BioPar.nh4_0;	% In mmol/m3
        BioPar.no2_in = BioPar.no2_0;	% In mmol/m3
        BioPar.n2_in = BioPar.n2_0;		% In mmol/m3

        % For the chemostat or mixed layer case, set up input values for all tracers
        % (typically, specify nutrients and set all biological terms to 0)
        %-------------------------------------------
        % Tracers:
    otherwise
        error('Error (experiment case not found)');
end



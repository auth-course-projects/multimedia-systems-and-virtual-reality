function register_config( confset )
%REGISTER_CONFIG Registers execution configuration struct in the global
%variables' workspace.
% 
%   confset: one of the pre-selected run configurations:
%               - 1: default in all, no huffman encode
%               - 2: default in all, huffman encode
%               - 3: marios mdct, zeros missing policy, no huffman encode
%               - 4: marios mdct, zeros missing policy, huffman encode
%            If no confset selected ( nargin = 0 ) then the 1st is
%            automatically selected.
% 

    global AACONFIG AACONFSET

    
    % Configuration set
    if ( nargin == 0 || isempty( confset ) )

        if ( isempty( AACONFSET ) )
        
            confset = ConfSets.Default; 
            
        else
            
            confset = AACONFSET; 
            
        end

    end
    
    % Initialize Config Struct
    if ( isempty( AACONFIG ) )
        
        %% Main config
        AACONFIG = struct( ...
            'DEBUG', false, ...
            'L1', struct( ...
                'WINDOW_SHAPE', 'KBD', ...
                'MDCT_METHOD', 'default', ...           % default or marios
                'SSC_FIRST_FRAME_TYPE', L1_SSC_Frametypes.OnlyLong, ...
                'SSC_ONLY_LONG_TEST', false, ...
                'L3_ENCODER_RUNNING', false, ...
                'SNR', struct( ...
                    'COMPUTE_METHOD', 'builtin', ...    % default or builtin
                    'MEAN_METHOD', 'rms' ...            % mean or rms
                ) ...
            ), ...
            'L2', struct( ...
                ...
            ), ...
            'L3', struct( ...
                'HUFFMAN_ENCODE', false, ...
                'ON_PREV_MISSING_POLICY', L3_PSYCHO_MissingPolicies.Zeros ...
            ) ...
        );
    
        %% Configuration sets
        switch confset

            case ConfSets.Default
                AACONFIG.L1.MDCT_METHOD = 'default';
                AACONFIG.L3.HUFFMAN_ENCODE = false;

            case ConfSets.Default_Huffman
                AACONFIG.L1.MDCT_METHOD = 'default';
                AACONFIG.L3.HUFFMAN_ENCODE = true;

            case ConfSets.Marios
                AACONFIG.L1.MDCT_METHOD = 'marios';
                AACONFIG.L3.HUFFMAN_ENCODE = false;

            case ConfSets.Marios_Huffman
                AACONFIG.L1.MDCT_METHOD = 'marios';
                AACONFIG.L3.HUFFMAN_ENCODE = true;

        end
        
        % Save configuration-set
        AACONFSET = confset;
        
    end

end

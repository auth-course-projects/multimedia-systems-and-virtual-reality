function AACSeq1 = AACoder1( fNameIn, confset )
%AACCODER1 Level-1 AAC Coder
%   
%   fNameIn: wav file's name ( on which the AAC Coder will be executed )
%   confset: execution configuration parameters as one of the pre-defined
%   configuration sets ( see ConfSets class )
% 
%   AACSeq1: Level-1 output struct containing info for each of the coder's
%   frames
% 

    % Configuration Set
    if ( nargin == 1 )
        
       confset = ConfSets.Marios;
        
    end

    %% Constants
    WINDOW_LENGTH = 2048;
    OVERLAP_LENGTH = WINDOW_LENGTH / 2;
    
    %% Global Config
    global AACONFIG
    register_config( confset )

    %% Read wav file
    [y, ~] = audioread( fNameIn );
    y = [ y; zeros( OVERLAP_LENGTH - rem( size( y, 1 ), OVERLAP_LENGTH ), 2 ) ];

    %% Frames extraction
    % Split audio signal in channels
    channel_frames_by_channel = L1_FILTERBANK_MDCT_buffer( y, WINDOW_LENGTH, OVERLAP_LENGTH );
    NFRAMES = size( channel_frames_by_channel, 2 );
    
    % Initialize output struct
    AACSeq1 = repmat( struct( ... 
            'frameType', '', 'winType', AACONFIG.L1.WINDOW_SHAPE, ...
            'chl', struct( 'frameF', [] ), ...
            'chr', struct( 'frameF', [] ) ...
        ), NFRAMES, 1 ...
    );

    % Check if Level-3 Encoder is running: add frameT to struct as, it will
    % be used in the psychoacoustic modeling stage of the encoder.
    if ( AACONFIG.L1.L3_ENCODER_RUNNING )
        
        for channel = 'lr'
        
            for frame_i = 1 : NFRAMES

                % Per Channel
                AACSeq1( frame_i ).(['ch' channel]).frameT = ...
                    channel_frames_by_channel( :, frame_i, strfind( 'lr', channel ) );

            end
        
        end
        
    end

    %% SSC: Find frame Type
    % first frame ( only right half has non-zero values ) is set arbitarily 
    % to OLS
    AACSeq1( 1 ).frameType = AACONFIG.L1.SSC_FIRST_FRAME_TYPE;
    for frame_i = 2: NFRAMES - 1

        AACSeq1( frame_i ).frameType = SSC(... 
            channel_frames_by_channel( :, frame_i, : ), ...
            channel_frames_by_channel( :, frame_i + 1, : ), ...
            AACSeq1( frame_i - 1 ).frameType ...
        );

    end
    % last frame - only left half has non-zero values - is set based on
    % previous frame's type
    if (  AACSeq1( frame_i ).frameType == L1_SSC_Frametypes.EightShort )
        
        AACSeq1( NFRAMES ).frameType = L1_SSC_Frametypes.LongStop;
        
    else
        
        AACSeq1( NFRAMES ).frameType = L1_SSC_Frametypes.OnlyLong;
        
    end

    %% FilterBank: Time-to-Frequency Mapping for each frame using MDCT
    for channel = 'lr'

        for frame_i = 1 : NFRAMES
            
            % Per Channel
            AACSeq1( frame_i ).(['ch' channel]).frameF = permute( filterbank( ...
                channel_frames_by_channel( :, frame_i, strfind( 'lr', channel ) ), ...
                AACSeq1( frame_i ).frameType, ...
                AACONFIG.L1.WINDOW_SHAPE ...
            ), [ 1, 3, 2 ] );

        end
    
    end
    
end


classdef SegyFile < File
    
    %
    %SegyFile Class
    % Open a SEG-Y file for reading or writing and get basic
    % information about the file, such as the format of the
    % text header and the byte order of the disk file
    %
    
    properties
        textheader;           % contains a text header object
        binaryheader;         % contains a binary header object
        extendedheader        % contains a cell array of extended headers
        traceheader;          % contains a trace header object
        trace;                % contains a trace object
        %
        %         computerEndian;       % output from computer()
        %                               %   string containing 'B' or 'L'
    end % end properties
    
    methods
        %Constructor/Destructor
        function obj = SegyFile(filename,varargin)
            %function obj = SegyFile(filname,varargin)
            %
            % Example:
            %   SegyFile('file.sgy','machineformat','ieee-be')
            %
            % Where:
            %   filename      = string containing full segy file name
            %   permission    = permissions for fopen(); default is 'r'
            %   machineformat = string containing 'ieee-be' or 'ieee-le'
            %                   for big and little endian (optional)
            %   textfmt       = string containing 'ebcdic' or 'ascii'
            %
            
            % process varargin
            
            %Superclass constructors
            if(nargin==0)
                filename = [];
            end
            obj = obj@File(filename,varargin{:});
            all=1;
            new=0;
            trch=1;
            if nargin > 0
                %   read contents of input arguments
                for i = 1:2:length(varargin)
                    name = lower(varargin{i});
                    value = varargin{i+1};
                    if(~ischar(name) || ~ischar(value))
                        error('Error: input to SegyFile() must be character strings');
                    end
                    switch name
                        case 'machineformat'
                            obj.machineformat = value;
                        case 'textfmt'
                            obj.textformat = value;
                        case 'mode'
                            obj.permission = value;
                        case 'all'
                            if any(strcmpi(value,{'1','yes','ok','true'}))
                                all=1;
                            elseif any(strcmpi(value,{'0','no','false'}))
                                all=0;
                            end
                        case 'traceheaders'
                            if any(strcmpi(value,{'1','yes','ok','true'}))
                                trch=1;
                            elseif any(strcmpi(value,{'0','no','false'}))
                                trch=0;
                            end
                        case 'new'
                            new=1;
                        otherwise
                    end
                end
                
                %   check byte order values
                if (~(strcmp(obj.machineformat,'ieee-be') || strcmp(obj.machineformat,'ieee-le')))
                    %warning('crewes:segy:SegyFile','endian argument not supplied or invalid. Checking file...');
                    %obj.machineformat = guessByteOrder(obj);
                end
                % if this is not a new file read in the values
                if ~new
                    if ~all
                        if trch
                        obj=readsegyheaders(obj,filename,varargin{:});
                        else
                        obj=readsegyheadersnotrch(obj,filename,varargin{:});
                        end
                        
                    else
                        obj=readallsegy(obj,filename,varargin{:});
                    end
                else
                    obj.textheader=TextHeader(filename,varargin{:});
                    obj.binaryheader=BinaryHeader(filename,varargin{:});
                    obj.extendedheader={};
                    obj.trace=Trace(filename,varargin{:});
                end
            end
        end
        function delete(obj)
            obj.closeFile();
        end
        
        
        function segywriteall(obj)
            segywrite(obj);
        end
        
        
    end % end methods
    
    methods (Static)
        ibm = ieee2ibm(ieee);
        ieee = ibm2ieee(ibm,fmt);
        
    end % end static methods
    
end % end classdef
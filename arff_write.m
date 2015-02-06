% ARFF_WRITE - Saves a MATLAB's struct array to file using ARFF file format.
%
%   ARFF_WRITE(arff_file, DATA, relname, nomspec)
%       arff_file => output file (.arff / .arff.gz extension)
%       DATA => struct array representing data and attributes (n x attrs)
%       relname => relation name (string)
%       nomspec => struct array defining nominal-specification attributes
%
%   NOTES:
%       Attribute name is taken from DATA struct fieldname and attribute
%       type is taken from field data-type.
%
%       Append "_class" to a DATA struct fieldname to save an attribute as
%       nominal-specification attribute and specify the nominal-names
%       inside NOMSPEC struct array using as fieldname the DATA struct's
%       fieldname and as content a cell array of names (string).
%
%       Append "_date" to a DATA struct fieldname and use numerical date
%       representation (using datenum) to save an attribute as date type 
%       (using 'yyyy-mm-dd HH:MM:SS' format in ARFF file).
%
%       TODO -- According to SPEC any attribute that contain space must be 
%       quoted using single quote char.
%
%       See ARFF format specification on WEKA site.

% Authors:
%   Valerio De Carolis          <valerio.decarolis@gmail.com>
%
%  28 September 2012 - University of Rome "La Sapienza" 

function [] = arff_write(arff_file, data, relname, nomspec)

    if nargin < 3
        error('MATLAB:input','Not enough inputs!');
    end
    
    if isempty(data) || ~isstruct(data)
        error('MATLAB:input','Please use struct data input!');
    end
    
    if isempty(arff_file)
        arff_file = sprintf('output-%d.arff', randi(1000,1));
    end
    
    if isempty(relname)
        relname = sprintf('relname-%d', randi(1000,1));
    end
    
    % check file extention
    [arff_path, arff_name, ext] = fileparts(arff_file);
    
    if strcmpi(ext,'.arff')
        
        % open file
        fid = fopen(arff_file, 'w+t');
        
    elseif strcmpi(ext,'.gz')
        
        % temp file using unique temp dir
        %   support multiple calls of arff_write in parallel with the same input file
        outdir = tempname;
        outfile = fullfile(outdir, arff_name);
        
        % open file
        fid = fopen(outfile, 'w+t');
    
    else
        error('%s is not a valid arff_file', arff_file);
    end
    
    % write relname
    fprintf(fid, '@RELATION %s\n\n', relname);
    
    % write attributes
    fields = fieldnames(data);
    ftypes = zeros(size(fields));
    
    for fn = 1 : length(fields)
        
        if isnumeric( data(1).(fields{fn}) )
            
            dt = strfind(fields{fn}, '_date');
            
            if isempty(dt)
                type = 'NUMERIC';
                ftypes(fn) = 0;
            else
                % check SimpleDateFormat (java.doc) to accept this instead of ISO-8601
                type = 'DATE "yyyy-mm-dd HH:MM:SS"';
                ftypes(fn) = 3;
                %name = fields{fn}(1:max(dt)-1);
            end
            
        elseif ischar( data(1).(fields{fn}) )
            
            ct = strfind(fields{fn}, '_class');
            
            if isempty(ct)
                type = 'STRING';
                ftypes(fn) = 2;
            else           
                if isstruct(nomspec) && isfield(nomspec, fields{fn}) && ...
                        iscell(nomspec.(fields{fn}))
                    
                    type = '{';

                    for k = 1 : length( nomspec.(fields{fn}) ) - 1
                        type = sprintf( '%s %s,', type, nomspec.(fields{fn}){k} );
                    end

                    type = sprintf('%s %s }', type, nomspec.(fields{fn}){k+1});

                else
                    fclose(fid);
                    error('MATLAB:input','Inferring class specification from data!');
                    % TODO inference
                end
                
                ftypes(fn) = 1;
                %name = fields{fn}(1:max(ct)-1);
            end
            
        else
            fclose(fid);
            error('MATLAB:input','Cannot convert %s field to ARFF format!', fields{fn});
        end
        
        fprintf(fid, '@ATTRIBUTE %s %s\n', fields{fn}, type);
        %fprintf(fid, '@ATTRIBUTE %s %s\n', name, type);
        
    end
    
    % write data
    fprintf(fid, '\n@DATA\n');
    content = '';
    
    for n = 1 : length(data)
       
        for fn = 1 : length(fields)
            
            if isempty(data(n).(fields{fn}))
                content = '?';
            else
                switch ftypes(fn)
                    case 0
                        content = num2str( data(n).(fields{fn}) );
                    case 1
                        content = data(n).(fields{fn});
                    case 2
                        content = data(n).(fields{fn});
                    case 3
                        content = ['"' datestr(data(n).(fields{fn}), 'yyyy-mm-dd HH:MM:SS') '"'];
                end
            end
            
            if fn < length(fields)
                fprintf(fid,'%s,', content);
            else
                fprintf(fid,'%s', content);
            end
            
        end
        
        fprintf(fid,'\n');
        
    end
    
    % close file
    fclose(fid);
    
    % remove temporary file & compress .arff
    if exist('outfile','var') && ~isempty(outfile)
        gzip(outfile, arff_path);
        delete(outfile);
        rmdir(outdir,'s');
    end

end

% References:
%   [1]: http://www.cs.waikato.ac.nz/ml/weka/arff.html

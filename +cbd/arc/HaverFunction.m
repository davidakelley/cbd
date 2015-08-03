classdef HaverFunction < handle
    
    
    
    properties
        fnName
        arguments
        output
    end
    
    methods
        function obj = HaverFunction(strIn)
            
            % Check for illegal charactars
            illegalChar = '"''';
            regexOut = regexpi(strIn, illegalChar);
            assert(isscalar(regexOut) && isempty(regexOut{1}), 'haver:HaverFunction:invalidInput');
            
            fnRegex = regexpi(strIn, '()@,');
            if isscalar(fnRegex) && isempty(fnRegex{1})
                obj.output = cbd.private.HaverSeries(strIn);
            elseif strcmpi(strIn(end), ')') % Calling function
                splitIn = strplit(strIn, '(');
                obj.fnName = splitIn{1};
                argStr = splitIn{2}(1:end-1);
                
                args = strsplit(argStr, ',');
                obj.arguments = cell(length(args),1);
                for iArg = 1:length(args)
                    if isempty(str2double(strIn)) % Haver Series
                        obj.arguments{iArg} = cbd.private.HaverFunction(args{iArg});
                    else % Number in function
                        obj.arguments{iArg} = str2double(strIn);
                    end
                end
                
                haver_fn = str2func(['cbd.' obj.fnName]);
                
                try
                    obj.output = haver_fn(obj.arguments{:});
                catch
                    error('haverpull:noFn', ['Undefined Haver transformation ' upper(seriesStruct.Transform) '.']);
                end
                
            else    % Single argument
                error('Not sure what''s going on.');
            end
            
        end
        
        
        
        %         function cbdFns = listCBDfns(obj)
        %             contents = dir('O:\PROJ_LIB\Presentations\Chartbook\Data\Dataset Creation\cbd');
        %             matfiles = cell(length(contents),1);
        %             for iFile = 1:length(contents)
        %                 [~,name,ext] = fileparts(contents(iFile).name);
        %                 if ~contents{iFile}.isdir && strcmpi(ext,'m');
        %                     matfiles{iFile} = name;
        %                 end
        %             end
        %             cbdFns = matfiles(cellfun(@isempty,matfiles));
        %         end
    end
    
end
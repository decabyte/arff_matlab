% Matlab function to read the given arff(.gz) file.
% The arff file is assumed to contain only numeric data plus
%  the last column/feature being nominal and named as 'class'.
%
% [data, classes, classnames, colnames] = READ_ARFF(arff_file)
%
% with
%  arff_file  -- the arff file path
%      (if it is compressed it will be decompressed on the fly into the temp folder)
%
% returns
%  data       -- matrix with the format: rows=subjects and cols=features
%  classes    -- cell column containing each subject's class
%  classnames -- cell column enumerating the different classes
%  
%
% author: Martin Dyrba (martin.dyrba@dzne.de)
%
function [data, classes, classnames, colnames] = read_arff(arff_file)
 
 % check for arff_matlab lib
 if (exist('arff_read.m', 'file') ~= 2)
  addpath 'arff_matlab'; % try to load arff_matlab toolbox if it is not already contained in the path
  if (exist('arff_read.m', 'file') ~= 2)
   error('can not find arff_matlab toolbox in path nor load it'); % should never happen, but just to make sure
  end
 end
 
 % read arff data for given arff
 [data, relname, nomspec] = arff_read(arff_file);
 
 colnames = fieldnames(data);
 if ~strcmp(colnames{length(colnames)}, 'class')
  error(['assumption violated: expected last arff data column to be class, but found: ', colnames{length(colnames)}]);
 end
 classnames = nomspec.('class');
 colnames(length(colnames)) = []; % remove class label from colnames
 
 % convert data struct to mat in desired format (rows: subjects, cols: features)
 data = struct2cell(data);
 data = reshape(data, size(data,1), size(data,3)); % reshape from 3dim to 2dim cell array
 data = data'; % transpose to rows=subjects and cols=features
 classes = data (:,size(data,2)); % extract cell column containing class information
 data(:, size(data,2)) = []; % delete class column from data
 data = cell2mat(data);

 % extract class label indices:
 % [~,classidx,~]=unique(classnames,'stable') 
end

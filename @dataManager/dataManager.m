% class definition for dataManager 
% dataManager is a tool for using hashes to interface between your code and your data
% the point is to make your code agnostic to WHERE the data is, but sensitive to WHAT the data is
% 
% see: https://github.com/sg-s/data-manager
% for more docs
% 
% created by Srinivas Gorur-Shandilya. Contact me at http://srinivas.gs/contact/


classdef dataManager < matlab.mixin.CustomDisplay
   properties
      verbosity  = 1;
      hash_table_loc
   end
   
    methods (Access = protected)
        function displayScalarObject(~)
            url = 'https://github.com/sg-s/data-manager/';
            fprintf(['<a href="' url '">dataManager</a> object']);
            fprintf([' (build ' strtrim(fileread([fileparts(fileparts(which(mfilename))) filesep 'build_number'])) ')\n'])

            fprintf('dataManager is a toolbox that lets you address data by what it is, rather than where it is\n\n')
            corelib.cprintf('_text','Usage:')
            fprintf('\n\n')

            corelib.cprintf('text','View hash table: ')
            fprintf('<a href="matlab:view(dataManager)">view(dataManager)</a>');

            corelib.cprintf('text','\nrehash current folder: ')
            fprintf('<a href="matlab:rehash(dataManager)">rehash(dataManager)</a>');

            corelib.cprintf('text','\nrehash specific folder: ')
            fprintf('rehash(dataManager,''path/to-folder/'')');

            corelib.cprintf('text','\nget path to a particular data file: ')
            fprintf('getPath(dataManager,''hash-of-data'')');

            corelib.cprintf('text','\nclean up; prune dead links: ')
            fprintf('<a href="matlab:cleanup(dataManager)">cleanup(dataManager)</a>');

            fprintf('\n \ndata-manager is free software, released under the GPL.\n');
            fprintf('\nbugs? <a href="mailto:datamanager@srinivas.gs">write to me.</a>\n');
        end % end displayScalarObject
  end % end protected methods


  methods

    function self = dataManager(verbosity)
    	if nargin == 0
    		self.verbosity = 0;
    	end

    	% determine hash table loc
    	if ispc 
    		self.hash_table_loc = [fileparts(which(mfilename)) filesep 'hash_table.mat'];
    	else
    		% use a hash table in a hidden folder in ~
    		self.hash_table_loc = '~/.dm_hash_table.mat';
    	end

    end

   end % end methods



end % end classdef
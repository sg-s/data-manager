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
      verbosity  = 10;
   end
   
    methods (Access = protected)
        function displayScalarObject(~)
            url = 'https://github.com/sg-s/data-manager/';
            fprintf(['<a href="' url '">dataManager</a> object']);
            fprintf([' (build ' strtrim(fileread([fileparts(which(mfilename)) oss 'build_number'])) ')\n'])

            fprintf('dataManager is a toolbox that lets you address data by what it is, rather than where it is\n\n')
            cprintf('_text','Usage:')
            fprintf('\n\n')

            cprintf('text','View hash table: ')
            fprintf('<a href="matlab:view(dataManager)">view(dataManager)</a>');

            cprintf('text','\nrehash current folder: ')
            fprintf('<a href="matlab:rehash(dataManager)">rehash(dataManager)</a>');

            cprintf('text','\nrehash specific folder: ')
            fprintf('rehash(dataManager,''path/to-folder/'')');

            cprintf('text','\nget path to a particular data file: ')
            fprintf('getPath(dataManager,''hash-of-data'')');

            cprintf('text','\nclean up; prune dead links: ')
            fprintf('<a href="matlab:cleanup(dataManager)">cleanup(dataManager)</a>');

            fprintf('\n \ndata-manager is free software, released under the GPL.\n');
            fprintf('\nbugs? <a href="mailto:datamanger@srinivas.gs">write to me.</a>\n');
        end % end displayScalarObject
   end % end protected methods


   methods


      function [paths] = getPath(dm,hash)
         % returns the path corresponding to a hash

         % load the hash table
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==2
            load([fileparts(which(mfilename)) oss 'hash_table.mat'])
         else
            error('Hash table empty.')
         end

         % look for the hash(es)
         if iscell(hash) 
         else
            hash = {hash};
         end
         paths = hash;

         % update the last retrieved 
         if exist('last_retrieved','var')
         else
            disp('No info on last retrieved, creating new variable...')
            last_retrieved = cell(length(all_hashes),1);
         end

         for i = 1:length(hash)
            this_index = find(strcmp(hash{i},all_hashes),1,'first');
            if isempty(this_index)
               disp('This hash was not found in the hash table:')
               disp(hash{i})
               error('Hash not found!')
            else
               paths{i} = all_paths{this_index};
               if dm.verbosity
                  disp([hash{i} '-> ' paths{i}])
               end

               if ~isdir(paths{i})
                  % check that the hash is correct
                  try
                     temp = md5(paths{i});
                  catch
                     Opt.Input = 'file';
                     temp = dataHash(paths{i},Opt);
                  end
                  if ~strcmp(hash{i},temp)
                     disp('File modified since last rehash. Your data has been modified, and the hashes do not match.')
                     disp('File name:')
                     disp(paths{i})
                     disp(['Requested hash is ' hash{i}])
                     disp(['Actual hash is ' temp])

                     cprintf('text','\nrehash the problematic file: ')
                     eval_string = ['rehash(dataManager,' char(39), paths{i} char(39) ')'];
                     fprintf(['<a href="matlab:' eval_string '">rehash this file</a>']);

                     error('hash check failed')
                  end
               end

               last_retrieved{this_index} = datestr(now);
            end
         end

         if length(paths) == 1
            paths = paths{1}; % return a string if possible
         end

         % save
         save([fileparts(which(mfilename)) oss 'hash_table.mat'],'last_retrieved','-append')
      end

      function rehash(dm,path_name)

         % load the hash table
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==2
            load([fileparts(which(mfilename)) oss 'hash_table.mat'])
         else
            all_hashes = {};
            all_paths = {};
            last_retrieved = {};
         end

         if nargin < 2
            path_name = cd;
         end

         % locate and read the dmignore file
         if exist([fileparts(which(mfilename)) oss 'dmignore.m'],'file') == 2
            lines = lineRead([fileparts(which(mfilename)) oss 'dmignore.m']);
         else
            error('No dmignore.m file found!')
         end

         % get all folders in the path
         all_folders = getAllFolders(path_name);

         % make sure there are no trailing slashes
         for i = 1:length(all_folders)
            if strcmp(all_folders{i}(end),oss)
               all_folders{i}(end) = '';
            end
         end

         % for each folder...
         for i = 1:length(all_folders)
            if dm.verbosity
               disp(all_folders{i})
            end
            % .... get all the files in this folder
            all_files = dir(all_folders{i});
            all_files = {all_files.name};
            % prepend the folder path to each of these
            for j = 1:length(all_files)
               all_files{j} = [all_folders{i} oss all_files{j}];
            end
            all_files = all_files(:);

            % ignore all hidden files and folders. 
            rm_this = false(length(all_files),1);
            for j = 1:length(all_files)
               if any(strfind(all_files{j},[oss '.']))
                  rm_this(j) = true;
               end
               if isdir(all_files{j})
                  rm_this(j) = true;
               end
            end
            all_files(rm_this) = []; clear rm_this

            % build a list of things to ignore from the dmignore file
            ignore_these = {};
            for j = 1:length(lines)
               this_line = lines{j};
               this_line(strfind(this_line,'%'):end) = [];
               if ~isempty(this_line)
                  ignore_these = [ignore_these this_line];
               end
            end

            % remove files with patterns in dmignore 
            rm_this = false(length(all_files),1);
            for j = 1:length(all_files)
               for k = 1:length(ignore_these)
                  if any(strfind(all_files{j},ignore_these{k}))
                     rm_this(j) = true;
                  end
               end
            end
            all_files(rm_this) = []; clear rm_this

            % grab hashes for all these files. 
            hashes = all_files;
            Opt.Input = 'file';
            for j = 1:length(all_files)
               disp(all_files{j})
               if dm.verbosity
                  disp(['Hashing:' all_files{i}])
               end
               % attempt to use system md5 first,
               try
                  hashes{j} = md5(all_files{j});
               catch
                  hashes{j} = dataHash(all_files{j},Opt);
               end
            end

            % add all these hashes to the main hash table, and overwrite if need be
            for j = 1:length(hashes)
               if isempty(find(strcmp(hashes{j},all_hashes),1,'first')) && isempty(find(strcmp(all_files{j},all_paths),1,'first'))
                  % completely new hash. simply add it. 
                  if dm.verbosity
                     disp(['New hash:' hashes{j}])
                  end
               else
                  rm_this = [];
                  % remove the old hash corresponding to the current path
                  if ~isempty(find(strcmp(all_files{j},all_paths),1,'first'))
                     rm_this = find(strcmp(all_files{j},all_paths),1,'first');
                  end
                  if dm.verbosity
                     disp(['hash exists already:' hashes{j}])
                  end

                  % and also remove the old path corresponding to the current hash
                  if ~isempty(find(strcmp(hashes{j},all_hashes),1,'first'))
                     rm_this = [rm_this find(strcmp(hashes{j},all_hashes),1,'first')];
                  end
                  rm_this = unique(rm_this);
                  all_hashes(rm_this) = [];
                  all_paths(rm_this) = [];
                  try
                     last_retrieved(rm_this) = [];
                  catch
                  end
               end 
               
               all_hashes = [all_hashes; hashes{j}];
               all_paths = [all_paths; all_files{j}];
               last_retrieved = [last_retrieved; ''];

            end

            % now we identify the folder we are in using a hash of all the hashes of the files in it
            folder_hash = dataHash(hashes);


            if isempty(find(strcmp(folder_hash,all_hashes),1,'first')) && isempty(find(strcmp(all_folders{i},all_paths),1,'first'))
               
               if dm.verbosity
                  disp('this folder hash does not exist in the hash table:')
                  disp(folder_hash)
               end
            else
               if dm.verbosity
                  disp('this folder hash is novel:')
                  disp(folder_hash)
               end
               rm_this = [];
               % remove the old hash corresponding to the current path
               if ~isempty(find(strcmp(all_folders{i},all_paths),1,'first'))
                  rm_this = find(strcmp(all_folders{i},all_paths),1,'first');
               end

               % and also remove the old path corresponding to the current hash
               if ~isempty(find(strcmp(folder_hash,all_hashes),1,'first'))
                  rm_this = [rm_this find(strcmp(folder_hash,all_hashes),1,'first')];
               end
               rm_this = unique(rm_this);
               all_hashes(rm_this) = [];
               all_paths(rm_this) = [];
               try
                  last_retrieved(rm_this) = [];
               catch
               end
            end
            all_hashes = [all_hashes; folder_hash];
            all_paths = [all_paths; all_folders{i}];
            last_retrieved = [last_retrieved; ''];


         end % end loop over all_folders
         % save this...
         disp('Saving...')
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==7
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','all_hashes','last_retrieved','-append')
         else
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','all_hashes','last_retrieved','-v7.3')
         end
         

      end % end function rehash

      function [] = view(dm,path_spec,sort_order)
          % load the hash table
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==2
            load([fileparts(which(mfilename)) oss 'hash_table.mat'])
         else
            disp('Hash table empty.')
            return
         end

         if nargin < 2
            path_spec = '';
         end
         if nargin < 3
            sort_order = 'la'; % last accessed 
         end

         if length(last_retrieved) < length(all_hashes)
            for i = length(last_retrieved)+1:length(all_hashes)
               last_retrieved{i} = '';
            end
         end

         % for sorting purposes, we combine the last retrieved with the hash
         lr_hash = last_retrieved;
         for i = 1:length(last_retrieved)
            if isempty(last_retrieved{i})
               lr_hash{i} = ['-------never--------   ' all_hashes{i}];
            else
               lr_hash{i} = [last_retrieved{i} '   ' all_hashes{i}];
            end
         end

         % sort the paths
         if strcmp(sort_order,'la')
            sorted_times = sortCell(lr_hash);
            for i = 1:length(all_hashes)
               % find this path in the original cell array
               this_loc = find(strcmp(sorted_times{i},lr_hash));
               if any(strfind(all_paths{this_loc},path_spec)) ||  isempty(path_spec)
                  
                  disp([sorted_times{i} '  '  all_paths{this_loc}])
               end
            end
         else
            sorted_paths = sortCell(all_paths);
            for i = 1:length(all_hashes)
               % find this path in the original cell array
               if any(strfind(sorted_paths{i},path_spec)) ||  isempty(path_spec)
                  this_loc = find(strcmp(sorted_paths{i},all_paths));
                  lts = last_retrieved{this_loc};
                  if isempty(lts)
                     lts = '-------never--------';
                  end
                  disp([all_hashes{this_loc} '     '  lts '    '  sorted_paths{i}])
               end
            end
         end
      end % end function



            
 

      function [] = cleanup(dm)
         % 1. remove paths in the hash table that point to files that no longer exist
          % load the hash table
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==2
            load([fileparts(which(mfilename)) oss 'hash_table.mat'])
         else
            disp('Hash table empty.')
            return
         end

         delete_me = false(length(all_hashes),1);
         for i = 1:length(all_hashes)
            if exist(all_paths{i},'file') == 2 || exist(all_paths{i},'dir') == 7
            else
               delete_me(i) = true;
            end
         end

         all_paths(delete_me) = [];
         all_hashes(delete_me) = [];

         if any(delete_me)
            disp(['Deleted ' oval(sum(delete_me)) ' entries from the hash table because they pointed to files that no longer existed.'])
         end

         % 2. remove entries in the hash table that match a pattern in the dmignore file
         % locate and read the dmignore file
         if exist([fileparts(which(mfilename)) oss 'dmignore.m'],'file') == 2
            lines = lineRead([fileparts(which(mfilename)) oss 'dmignore.m']);
         else
            error('No dmignore.m file found!')
         end

         % build a list of things to ignore from the dmignore file
         ignore_these = {};
         for j = 1:length(lines)
            this_line = lines{j};
            this_line(strfind(this_line,'%'):end) = [];
            if ~isempty(this_line)
               ignore_these = [ignore_these this_line];
            end
         end

         delete_me = false(length(all_paths),1);
         for i = 1:length(all_paths)
            for j = 1:length(ignore_these)
               if any(strfind(all_paths{i},ignore_these{j}))
                  delete_me(i) = true;
               end
            end
         end

         all_paths(delete_me) = [];
         all_hashes(delete_me) = [];
         last_retrieved(delete_me) = [];

         if any(delete_me)
            disp(['Deleted ' oval(sum(delete_me)) ' entries from the hash table because they matched patterns defined in dmignore.m'])
         end


         % save this...
         disp('Saving...')
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==7
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','all_hashes','last_retrieved','-append')
         else
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','last_retrieved','all_hashes','-v7.3')
         end

      end % end cleanup function
   end % end methods
end % end classdef
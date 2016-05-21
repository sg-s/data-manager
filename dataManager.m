% class definition for dataManager 
% dataManager is a tool for using hashes to interface between your code and your data
% the point is to make your code agnostic to WHERE the data is, but sensitive to WHAT the data is
% 
% see: https://github.com/sg-s/data-manager
% for more docs
% 
% created by Srinivas Gorur-Shandilya. Contact me at http://srinivas.gs/contact/


classdef dataManager
   properties
   end
   
   methods

      function [paths] = getPath(~,hash)
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
            last_retrieved = cell(length(all_hashes),1);
         end

         for i = 1:length(hash)
            if isempty(find(strcmp(hash{i},all_hashes),1,'first'))
               disp('This hash was not found in the hash table:')
               disp(hash{i})
               error('Hash not found!')
            else
               paths{i} = all_paths{find(strcmp(hash{i},all_hashes),1,'first')};
               last_retrieved{i} = datestr(now);
            end
         end

         if length(paths) == 1
            paths = paths{1}; % return a string if possible
         end

         % save
         save([fileparts(which(mfilename)) oss 'hash_table.mat'],'last_retrieved','-append')
      end

      function rehash(~,path_name)

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

         % get all folders in the path
         all_folders = getAllFolders(path_name);

         % make sure there are no trailing slashes
         for i = 1:length(all_folders)
            if strcmp(all_folders{i}(end),'/')
               all_folders{i}(end) = '';
            end
         end

         % for each folder...
         for i = 1:length(all_folders)
            % .... get all the files in this folder
            all_files = dir(all_folders{i});
            all_files = {all_files.name};
            % prepend the folder path to each of these
            for j = 1:length(all_files)
               all_files{j} = [all_folders{i} oss all_files{j}];
            end
            all_files = all_files(:);

            % ignore all hidden files and folders
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


            % grab hashes for all these files. 
            hashes = all_files;
            Opt.Input = 'file';
            for j = 1:length(all_files)
               disp(all_files{j})
               hashes{j} = dataHash(all_files{j},Opt);
            end

            % add all these hashes to the main hash table, and overwrite if need be
            for j = 1:length(hashes)
               if isempty(find(strcmp(hashes{j},all_hashes),1,'first')) && isempty(find(strcmp(all_files{j},all_paths),1,'first'))
                  % completely new hash. simply add it. 
               else
                  rm_this = [];
                  % remove the old hash corresponding to the current path
                  if ~isempty(find(strcmp(all_files{j},all_paths),1,'first'))
                     rm_this = find(strcmp(all_files{j},all_paths),1,'first');
                  end

                  % and also remove the old path corresponding to the current hash
                  if ~isempty(find(strcmp(hashes{j},all_hashes),1,'first'))
                     rm_this = [rm_this find(strcmp(hashes{j},all_hashes),1,'first')];
                  end
                  rm_this = unique(rm_this);
                  all_hashes(rm_this) = [];
                  all_paths(rm_this) = [];
               end 
               
               all_hashes = [all_hashes; hashes{j}];
               all_paths = [all_paths; all_files{j}];

            end

            % now we identify the folder we are in using a hash of all the hashes of the files in it
            folder_hash = dataHash(hashes);
            if isempty(find(strcmp(folder_hash,all_hashes),1,'first')) && isempty(find(strcmp(all_folders{i},all_paths),1,'first'))
            else
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
            end
            all_hashes = [all_hashes; folder_hash];
            all_paths = [all_paths; all_folders{i}];


         end % end loop over all_folders
         % save this...
         disp('Saving...')
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==7
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','all_hashes','-append')
         else
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','all_hashes','-v7.3')
         end
         

      end % end function rehash

      function [] = view(dm)
          % load the hash table
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==2
            load([fileparts(which(mfilename)) oss 'hash_table.mat'])
         else
            disp('Hash table empty.')
            return
         end
         for i = 1:length(all_hashes)
            disp([all_hashes{i} '    ' all_paths{i}])
         end
      end

      function [] = cleanup(dm)
         % removes paths in the hash table that point to files that no longer exist

          % load the hash table
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==2
            load([fileparts(which(mfilename)) oss 'hash_table.mat'])
         else
            disp('Hash table empty.')
            return
         end

         delete_me = false(length(all_hashes),1);
         for i = 1:length(all_hashes)
            if exist(all_paths{i},'file') ~= 2
               delete_me(i) = true;
            end
         end

         all_paths(delete_me) = [];
         all_hashes(delete_me) = [];

         disp(['Deleted ' oval(sum(delete_me)) ' entries from the hash table'])

         % save this...
         disp('Saving...')
         if exist([fileparts(which(mfilename)) oss 'hash_table.mat'],'file')==7
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','all_hashes','-append')
         else
            save([fileparts(which(mfilename)) oss 'hash_table.mat'],'all_paths','all_hashes','-v7.3')
         end

      end % end cleanup function
   end % end methods
end % end classdef
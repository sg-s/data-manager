function rehash(dm,path_name)

   % load the hash table
   if exist(dm.hash_table_loc,'file')==2
      load(dm.hash_table_loc)
   else
      all_hashes = {};
      all_paths = {};
      last_retrieved = {};
   end

   if nargin < 2
      path_name = cd;
   end

   % locate and read the dmignore file
   if exist([fileparts(fileparts(which('dataManager'))) filesep 'dmignore.m'],'file') == 2
      lines = filelib.read([fileparts(fileparts(which('dataManager'))) filesep 'dmignore.m']);
   else
      error('No dmignore.m file found!')
   end

   % get all folders in the path
   all_folders = filelib.getAllFolders(path_name);

   % make sure there are no trailing slashes
   for i = 1:length(all_folders)
      if strcmp(all_folders{i}(end),filesep)
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
         all_files{j} = [all_folders{i} filesep all_files{j}];
      end
      all_files = all_files(:);

      % ignore all hidden files and folders. 
      rm_this = false(length(all_files),1);
      for j = 1:length(all_files)
         if any(strfind(all_files{j},[filesep '.']))
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
         if dm.verbosity
            disp(['Hashing:' all_files{j}])
         end

         hashes{j} = hashlib.md5hash(all_files{j},'File');

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
      folder_hash = hashlib.md5hash([hashes{:}]);


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
   if exist(dm.hash_table_loc,'file') == 7
      save(dm.hash_table_loc,'all_paths','all_hashes','last_retrieved','-append')
   else
      save(dm.hash_table_loc,'all_paths','all_hashes','last_retrieved','-v7.3')
   end

end % end function rehash
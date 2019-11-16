function [] = cleanup(dm)
   % 1. remove paths in the hash table that point to files that no longer exist
    % load the hash table
   if exist([fileparts(which(mfilename)) filesep 'hash_table.mat'],'file')==2
      load([fileparts(which(mfilename)) filesep 'hash_table.mat'])
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
   if exist([fileparts(which(mfilename)) filesep 'dmignore.m'],'file') == 2
      lines = lineRead([fileparts(which(mfilename)) filesep 'dmignore.m']);
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
   if exist([fileparts(which(mfilename)) filesep 'hash_table.mat'],'file')==7
      save([fileparts(which(mfilename)) filesep 'hash_table.mat'],'all_paths','all_hashes','last_retrieved','-append')
   else
      save([fileparts(which(mfilename)) filesep 'hash_table.mat'],'all_paths','last_retrieved','all_hashes','-v7.3')
   end

end % end cleanup function